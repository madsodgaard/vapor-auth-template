@testable import App
import Fluent
import XCTVapor
import Crypto

final class AuthenticationTests: XCTestCase {
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
    
    func testGettingCurrentUser() throws {
        let user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123", isAdmin: true)
        try app.repositories.users.create(user).wait()
        
        try app.test(.GET, "api/auth/me", user: user, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(UserDTO.self, res) { userContent in
                XCTAssertEqual(userContent.email, "test@test.com")
                XCTAssertEqual(userContent.fullName, "Test User")
                XCTAssertEqual(userContent.isAdmin, true)
                XCTAssertEqual(userContent.id, user.id)
            }
        })
    }
}
