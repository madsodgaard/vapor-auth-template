import Vapor
import Fluent

protocol EmailTokenRepository: Repository {
    func find(token: String) -> EventLoopFuture<EmailToken?>
    func create(_ emailToken: EmailToken) -> EventLoopFuture<Void>
    func delete(_ emailToken: EmailToken) -> EventLoopFuture<Void>
    func find(userID: UUID) -> EventLoopFuture<EmailToken?>
}

struct DatabaseEmailTokenRepository: EmailTokenRepository, DatabaseRepository {
    let database: Database
    
    func find(token: String) -> EventLoopFuture<EmailToken?> {
        return EmailToken.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func create(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        return emailToken.create(on: database)
    }
    
    func delete(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        return emailToken.delete(on: database)
    }
    
    func find(userID: UUID) -> EventLoopFuture<EmailToken?> {
        EmailToken.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
    }
}

extension Application.Repositories {
    var emailTokens: EmailTokenRepository {
        guard let factory = storage.makeEmailTokenRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (EmailTokenRepository)) {
        storage.makeEmailTokenRepository = make
    }
}
