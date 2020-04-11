@testable import App
import Fluent
import XCTVapor

final class RefreshTokenRepositoryTests: XCTestCase {
    var app: Application!
    var repository: RefreshTokenRepository!
    var user: User!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        repository = DatabaseRefreshTokenRepository(database: app.db)
        try app.autoMigrate().wait()
        user = User(fullName: "Test User", email: "test@test.com", passwordHash: "123")
    }
    
    override func tearDownWithError() throws {
        try app.migrator.revertAllBatches().wait()
        app.shutdown()
    }
    
    func testCreatingToken() throws {
        try user.create(on: app.db).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID())
        try repository.create(token).wait()
        
        XCTAssertNotNil(token.id)
        
        let tokenRetrieved = try RefreshToken.find(token.id, on: app.db).wait()
        XCTAssertNotNil(tokenRetrieved)
        XCTAssertEqual(tokenRetrieved!.$user.id, try user.requireID())
    }
    
    func testFindingTokenById() throws {
        try user.create(on: app.db).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID())
        try token.create(on: app.db).wait()
        let tokenId = try token.requireID()
        let tokenFound = try repository.find(id: tokenId).wait()
        XCTAssertNotNil(tokenFound)
    }
    
    // TODO: Requires to reset the middleware of the database... so lets do that when my PR gets merged.
    func testFindingTokenByTokenString() throws {
        try user.create(on: app.db).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID())
        try token.create(on: app.db).wait()
        let tokenFound = try repository.find(token: "123").wait()
        XCTAssertNotNil(tokenFound)
    }
    
    func testDeletingToken() throws {
        try user.create(on: app.db).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID())
        try token.create(on: app.db).wait()
        let tokenCount = try RefreshToken.query(on: app.db).count().wait()
        XCTAssertEqual(tokenCount, 1)
        try repository.delete(token).wait()
        let newTokenCount = try RefreshToken.query(on: app.db).count().wait()
        XCTAssertEqual(newTokenCount, 0)
    }
    
    func testGetCount() throws {
        try user.create(on: app.db).wait()
        let token = try RefreshToken(token: "123", userID: user.requireID())
        try token.create(on: app.db).wait()
        let tokenCount = try repository.count().wait()
        XCTAssertEqual(tokenCount, 1)
    }
}
    

