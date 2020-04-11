import Vapor
import Fluent

protocol RefreshTokenRepository: Repository {
    func create(_ token: RefreshToken) -> EventLoopFuture<Void>
    func find(id: UUID?) -> EventLoopFuture<RefreshToken?>
    func find(token: String) -> EventLoopFuture<RefreshToken?>
    func delete(_ token: RefreshToken) -> EventLoopFuture<Void>
    func count() -> EventLoopFuture<Int>
    func delete(for userID: UUID) -> EventLoopFuture<Void>
}

struct DatabaseRefreshTokenRepository: RefreshTokenRepository, DatabaseRepository {
    let database: Database
    
    func create(_ token: RefreshToken) -> EventLoopFuture<Void> {
        return token.create(on: database)
    }
    
    func find(id: UUID?) -> EventLoopFuture<RefreshToken?> {
        return RefreshToken.find(id, on: database)
    }
    
    func find(token: String) -> EventLoopFuture<RefreshToken?> {
        return RefreshToken.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func delete(_ token: RefreshToken) -> EventLoopFuture<Void> {
        token.delete(on: database)
    }
    
    func count() -> EventLoopFuture<Int> {
        return RefreshToken.query(on: database)
            .count()
    }
    
    func delete(for userID: UUID) -> EventLoopFuture<Void> {
        RefreshToken.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}

extension Application.Repositories {
    var refreshTokens: RefreshTokenRepository {
        guard let factory = storage.makeRefreshTokenRepository else {
            fatalError("RefreshToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (RefreshTokenRepository)) {
        storage.makeRefreshTokenRepository = make
    }
}
