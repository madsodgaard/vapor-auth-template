@testable import App
import Fluent
import XCTVapor

final class PasswordTokenRepositoryTests: XCTestCase {
    var app: Application!
    var repository: PasswordTokenRepository!
    var user: User!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        repository = DatabasePasswordTokenRepository(database: app.db)
        try app.autoMigrate().wait()
        user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
        try user.create(on: app.db).wait()
    }
    
    override func tearDownWithError() throws {
        try app.migrator.revertAllBatches().wait()
        app.shutdown()
    }
    
    func testFindByUserID() throws {
        let userID = try user.requireID()
        let token = PasswordToken(userID: userID, token: "123")
        try token.create(on: app.db).wait()
        try XCTAssertNotNil(repository.find(userID: userID).wait())
    }
    
    func testFindByToken() throws {
        let token = PasswordToken(userID: try user.requireID(), token: "token123")
        try token.create(on: app.db).wait()
        try XCTAssertNotNil(repository.find(token: "token123").wait())
    }
    
    func testCount() throws {
        let token = PasswordToken(userID: try user.requireID(), token: "token123")
        let token2 = PasswordToken(userID: try user.requireID(), token: "token123")
        try [token, token2].create(on: app.db).wait()
        let count = try repository.count().wait()
        XCTAssertEqual(count, 2)
    }
    
    func testCreate() throws {
        let token = PasswordToken(userID: try user.requireID(), token: "token123")
        try repository.create(token).wait()
        try XCTAssertNotNil(PasswordToken.find(try token.requireID(), on: app.db).wait())
    }
    
    func testDelete() throws {
        let token = PasswordToken(userID: try user.requireID(), token: "token123")
        try token.create(on: app.db).wait()
        try repository.delete(token).wait()
        let count = try PasswordToken.query(on: app.db).count().wait()
        XCTAssertEqual(count, 0)
    }
    
}
    

