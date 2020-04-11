@testable import App
import Vapor

final class TestPasswordTokenRepository: PasswordTokenRepository, TestRepository {
    var eventLoop: EventLoop
    var tokens: [PasswordToken]
    
    init(tokens: [PasswordToken], eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.tokens = tokens
    }
    
    func find(userID: UUID) -> EventLoopFuture<PasswordToken?> {
        let token = tokens.first(where: { $0.$user.id == userID })
        return eventLoop.makeSucceededFuture(token)
    }
    
    func find(token: String) -> EventLoopFuture<PasswordToken?> {
        let token = tokens.first(where: { $0.token == token })
        return eventLoop.makeSucceededFuture(token)
    }
    
    func count() -> EventLoopFuture<Int> {
        return eventLoop.makeSucceededFuture(tokens.count)
    }
    
    func create(_ passwordToken: PasswordToken) -> EventLoopFuture<Void> {
        tokens.append(passwordToken)
        return eventLoop.makeSucceededFuture(())
    }

    
    func delete(_ passwordToken: PasswordToken) -> EventLoopFuture<Void> {
        tokens.removeAll(where: { passwordToken.id == $0.id })
        return eventLoop.makeSucceededFuture(())
    }
    
    func delete(for userID: UUID) -> EventLoopFuture<Void> {
        tokens.removeAll(where: { $0.$user.id == userID })
        return eventLoop.makeSucceededFuture(())
    }
}
