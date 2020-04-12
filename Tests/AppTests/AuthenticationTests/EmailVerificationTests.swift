
@testable import App
import Fluent
import XCTVapor
import Crypto

final class EmailVerificationTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    let verifyURL = "api/auth/email-verification"
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        self.testWorld = try TestWorld(app: app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testVerifyingEmailHappyPath() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        let expectedHash = SHA256.hash("token123")
        
        let emailToken = EmailToken(userID: try user.requireID(), token: expectedHash)
        try app.repositories.emailTokens.create(emailToken).wait()
        
        try app.test(.GET, verifyURL, beforeRequest: { req in
            try req.query.encode(["token": "token123"])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try XCTUnwrap(app.repositories.users.find(id: user.id!).wait())
            XCTAssertEqual(user.isEmailVerified, true)
            let token = try app.repositories.emailTokens.find(userID: user.requireID()).wait()
            XCTAssertNil(token)
        })
    }
    
    func testVerifyingEmailWithInvalidTokenFails() throws {
        try app.test(.GET, verifyURL, beforeRequest: { req in
            try req.query.encode(["token": "blabla"])
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.emailTokenNotFound)
        })
    }
    
    func testVerifyingEmailWithExpiredTokenFails() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        let expectedHash = SHA256.hash("token123")
        let emailToken = EmailToken(userID: try user.requireID(), token: expectedHash, expiresAt: Date().addingTimeInterval(-Constants.EMAIL_TOKEN_LIFETIME - 1) )
        try app.repositories.emailTokens.create(emailToken).wait()
        
        try app.test(.GET, verifyURL, beforeRequest: { req in
            try req.query.encode(["token": "token123"])
        }, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.emailTokenHasExpired)
        })
    }
    
    func testResendEmailVerification() throws {
        app.randomGenerators.use(.rigged(value: "emailtoken"))
        
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try app.repositories.users.create(user).wait()
        
        let content = SendEmailVerificationRequest(email: "test@test.com")
        
        try app.test(.POST, "api/auth/email-verification", content: content, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let emailToken = try app.repositories.emailTokens.find(token: SHA256.hash("emailtoken")).wait()
            XCTAssertNotNil(emailToken)
            
            let job = try XCTUnwrap(app.queues.test.first(EmailJob.self))
            XCTAssertEqual(job.recipient, "test@test.com")
            XCTAssertEqual(job.email.templateName, "email_verification")
            XCTAssertEqual(job.email.templateData["verify_url"], "http://api.local/auth/email-verification?token=emailtoken")
        })
    }
}


