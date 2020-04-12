@testable import App
import Vapor
import Crypto

class TestRefreshTokenRepository: RefreshTokenRepository, TestRepository {
    var tokens: [RefreshToken]
    var eventLoop: EventLoop
    
    init(tokens: [RefreshToken] = [], eventLoop: EventLoop) {
        self.tokens = tokens
        self.eventLoop = eventLoop
    }
    
    func create(_ token: RefreshToken) -> EventLoopFuture<Void> {
        token.id = UUID()
        tokens.append(token)
        return eventLoop.makeSucceededFuture(())
    }
    
    func find(id: UUID?) -> EventLoopFuture<RefreshToken?> {
        let token = tokens.first(where: { $0.id == id})
        return eventLoop.makeSucceededFuture(token)
    }
    
    func find(token: String) -> EventLoopFuture<RefreshToken?> {
        let token = tokens.first(where: { $0.token == token })
        return eventLoop.makeSucceededFuture(token)
    }
    
    func delete(_ token: RefreshToken) -> EventLoopFuture<Void> {
        tokens.removeAll(where: { $0.id == token.id })
        return eventLoop.makeSucceededFuture(())
     }
    
    func count() -> EventLoopFuture<Int> {
        return eventLoop.makeSucceededFuture(tokens.count)
    }
    
    func delete(for userID: UUID) -> EventLoopFuture<Void> {
        tokens.removeAll(where: { $0.$user.id == userID })
        return eventLoop.makeSucceededFuture(())
    }
}
