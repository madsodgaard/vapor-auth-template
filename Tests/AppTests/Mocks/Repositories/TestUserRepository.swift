@testable import App
import Vapor
import Fluent

class TestUserRepository: UserRepository, TestRepository {
    var users: [User]
    var eventLoop: EventLoop
    
    init(users: [User] = [User](), eventLoop: EventLoop) {
        self.users = users
        self.eventLoop = eventLoop
    }
    
    func create(_ user: User) -> EventLoopFuture<Void> {
        user.id = UUID()
        users.append(user)
        return eventLoop.makeSucceededFuture(())
    }
    
    func delete(id: UUID) -> EventLoopFuture<Void> {
        users.removeAll(where: { $0.id == id })
        return eventLoop.makeSucceededFuture(())
    }
    
    func all() -> EventLoopFuture<[User]> {
        return eventLoop.makeSucceededFuture(users)
    }
    
    func find(id: UUID?) -> EventLoopFuture<User?> {
        let user = users.first(where: { $0.id == id })
        return eventLoop.makeSucceededFuture(user)
    }
    
    func find(email: String) -> EventLoopFuture<User?> {
        let user = users.first(where: { $0.email == email })
        return eventLoop.makeSucceededFuture(user)
    }
    
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void> where Field : QueryableProperty, Field.Model == User {
        let user = users.first(where: { $0.id == userID })!
        user[keyPath: field].value = value
        return eventLoop.makeSucceededFuture(())
    }
    
    func count() -> EventLoopFuture<Int> {
        return eventLoop.makeSucceededFuture(users.count)
    }
}
