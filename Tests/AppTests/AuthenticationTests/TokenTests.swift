@testable import App
import Fluent
import XCTVapor
import Crypto

final class TokenTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    let accessTokenPath = "api/auth/accessToken"
    var user: User!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        self.testWorld = TestWorld(app: app)
        
        user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testRefreshAccessToken() throws {
        app.randomGenerators.use(.rigged(value: "refreshtoken"))
        
        try app.repositories.users.create(user).wait()
        let token = try user.generateRefreshToken(generator: app.random)
        let refreshToken = token.token
        try app.repositories.refreshTokens.create(token).wait()
        let tokenID = try token.requireID()
        
        let accessTokenRequest = AccessTokenRequest(refreshToken: refreshToken)
        
        try app.test(.POST, accessTokenPath, content: accessTokenRequest, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(AccessTokenResponse.self, res) { response in
                XCTAssert(!response.accessToken.isEmpty)
                XCTAssertEqual(response.refreshToken, "refreshtoken")
            }
            let deletedToken = try app.repositories.refreshTokens.find(id: tokenID).wait()
            XCTAssertNil(deletedToken)
            let newToken = try app.repositories.refreshTokens.find(token: SHA256.hash("refreshtoken")).wait()
            XCTAssertNotNil(newToken)
        })
    }
    
    func testRefreshAccessTokenFailsWithExpiredRefreshToken() throws {
        try app.repositories.users.create(user).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID(), expiresAt: Date().addingTimeInterval(-60))
        let refreshToken = token.token
        try app.repositories.refreshTokens.create(token).wait()
        
        let accessTokenRequest = AccessTokenRequest(refreshToken: refreshToken)

        try app.test(.POST, accessTokenPath, content: accessTokenRequest, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.refreshTokenHasExpired)
        })
    }
}
