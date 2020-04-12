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
        self.testWorld = try TestWorld(app: app)
        
        user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testRefreshAccessToken() throws {
        app.randomGenerators.use(.rigged(value: "secondrefreshtoken"))
        
        try app.repositories.users.create(user).wait()
        
        let refreshToken = try RefreshToken(token: SHA256.hash("firstrefreshtoken"), userID: user.requireID())
        
        try app.repositories.refreshTokens.create(refreshToken).wait()
        let tokenID = try refreshToken.requireID()
        
        let accessTokenRequest = AccessTokenRequest(refreshToken: "firstrefreshtoken")
        
        try app.test(.POST, accessTokenPath, content: accessTokenRequest, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(AccessTokenResponse.self, res) { response in
                XCTAssert(!response.accessToken.isEmpty)
                XCTAssertEqual(response.refreshToken, "secondrefreshtoken")
            }
            let deletedToken = try app.repositories.refreshTokens.find(id: tokenID).wait()
            XCTAssertNil(deletedToken)
            let newToken = try app.repositories.refreshTokens.find(token: SHA256.hash("secondrefreshtoken")).wait()
            XCTAssertNotNil(newToken)
        })
    }
    
    func testRefreshAccessTokenFailsWithExpiredRefreshToken() throws {
        try app.repositories.users.create(user).wait()
        let token = try RefreshToken(token: SHA256.hash("123"), userID: user.requireID(), expiresAt: Date().addingTimeInterval(-60))
        
        try app.repositories.refreshTokens.create(token).wait()
        
        let accessTokenRequest = AccessTokenRequest(refreshToken: "123")

        try app.test(.POST, accessTokenPath, content: accessTokenRequest, afterResponse: { res in
            XCTAssertResponseError(res, AuthenticationError.refreshTokenHasExpired)
        })
    }
}
