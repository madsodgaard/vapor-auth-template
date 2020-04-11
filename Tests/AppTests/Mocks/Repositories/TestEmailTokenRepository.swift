@testable import App
import Vapor

class TestEmailTokenRepository: EmailTokenRepository, TestRepository {
    var tokens: [EmailToken]
    var eventLoop: EventLoop
    
    init(tokens: [EmailToken] = [], eventLoop: EventLoop) {
        self.tokens = tokens
        self.eventLoop = eventLoop
    }
    
    func find(token: String) -> EventLoopFuture<EmailToken?> {
        let token = tokens.first(where: { $0.token == token })
        return eventLoop.makeSucceededFuture(token)
    }
    
    func create(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        tokens.append(emailToken)
        return eventLoop.makeSucceededFuture(())
    }
    
    func delete(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        tokens.removeAll(where: { $0.id == emailToken.id })
        return eventLoop.makeSucceededFuture(())
    }
    
    
    func find(userID: UUID) -> EventLoopFuture<EmailToken?> {
        let token = tokens.first(where: { $0.$user.id == userID })
        return eventLoop.makeSucceededFuture(token)
    }
}
