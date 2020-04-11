@testable import App
import Fluent
import XCTVapor
import Crypto

final class ResetPasswordTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        self.testWorld = try TestWorld(app: app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testResetPassword() throws {
        app.randomGenerators.use(.rigged(value: "passwordtoken"))
        
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        
        let resetPasswordRequest = ResetPasswordRequest(email: "test@test.com")
        try app.test(.POST, "api/auth/reset-password", content: resetPasswordRequest, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let passwordToken = try app.repositories.passwordTokens.find(token: SHA256.hash("passwordtoken")).wait()
            XCTAssertNotNil(passwordToken)
            
            let resetPasswordJob = try XCTUnwrap(app.queues.test.first(EmailJob.self))
            XCTAssertEqual(resetPasswordJob.recipient, "test@test.com")
            XCTAssertEqual(resetPasswordJob.email.templateName, "reset_password")
            XCTAssertEqual(resetPasswordJob.email.templateData["reset_url"], "http://frontend.local/auth/reset-password?token=passwordtoken")
        })
    }
    
    func testResetPasswordSucceedsWithNonExistingEmail() throws {
        let resetPasswordRequest = ResetPasswordRequest(email: "none@test.com")
        try app.test(.POST, "api/auth/reset-password", content: resetPasswordRequest, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let tokenCount = try app.repositories.passwordTokens.count().wait()
            XCTAssertFalse(app.queues.test.contains(EmailJob.self))
            XCTAssertEqual(tokenCount, 0)
        })
    }
    
    func testRecoverAccount() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "oldpassword")
        try app.repositories.users.create(user).wait()
        let token = try PasswordToken(userID: user.requireID(), token: SHA256.hash("passwordtoken"))
        let existingToken = try PasswordToken(userID: user.requireID(), token: "token2")
        
        try app.repositories.passwordTokens.create(token).wait()
        try app.repositories.passwordTokens.create(existingToken).wait()
        
        let recoverRequest = RecoverAccountRequest(password: "newpassword", confirmPassword: "newpassword", token: "passwordtoken")
        
        try app.test(.POST, "api/auth/recover", content: recoverRequest, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let user = try app.repositories.users.find(id: user.requireID()).wait()!
            try XCTAssertTrue(BCryptDigest().verify("newpassword", created: user.passwordHash))
            let count = try app.repositories.passwordTokens.count().wait()
            XCTAssertEqual(count, 0)
        })
    }
    
    func testRecoverAccountWithExpiredTokenFails() throws {
        let token = PasswordToken(userID: UUID(), token: SHA256.hash("passwordtoken"), expiresAt: Date().addingTimeInterval(-60))
        try app.repositories.passwordTokens.create(token).wait()
        
        let recoverRequest = RecoverAccountRequest(password: "password", confirmPassword: "password", token: "passwordtoken")
        try app.test(.POST, "api/auth/recover", content: recoverRequest, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.passwordTokenHasExpired)
        })
    }
    
    func testRecoverAccountWithInvalidTokenFails() throws {
        let recoverRequest = RecoverAccountRequest(password: "password", confirmPassword: "password", token: "sdfsdfsf")
        try app.test(.POST, "api/auth/recover", content: recoverRequest, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.invalidPasswordToken)
        })
    }
    
    func testRecoverAccountWithNonMatchingPasswordsFail() throws {
        let recoverRequest = RecoverAccountRequest(password: "password", confirmPassword: "password123", token: "token")
        try app.test(.POST, "api/auth/recover", content: recoverRequest, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.passwordsDontMatch)
        })
    }
    
    func testVerifyPasswordToken() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        let passwordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash("token"))
        try app.repositories.passwordTokens.create(passwordToken).wait()
        
        try app.test(.GET, "api/auth/reset-password/verify?token=token", afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        })
    }
    
    func testVerifyPasswordTokenFailsWithInvalidToken() throws {
        try app.test(.GET, "api/auth/reset-password/verify?token=invalidtoken", afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.invalidPasswordToken)
        })
    }
    
    func testVerifyPasswordTokenFailsWithExpiredToken() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        let passwordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash("token"), expiresAt: Date().addingTimeInterval(-60))
        try app.repositories.passwordTokens.create(passwordToken).wait()
        
        try app.test(.GET, "api/auth/reset-password/verify?token=token", afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.passwordTokenHasExpired)
            let tokenCount = try app.repositories.passwordTokens.count().wait()
            XCTAssertEqual(tokenCount, 0)
        })
    }
}
