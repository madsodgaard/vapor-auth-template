import Vapor
import Fluent

protocol UserRepository: Repository {
    func create(_ user: User) -> EventLoopFuture<Void>
    func delete(id: UUID) -> EventLoopFuture<Void>
    func all() -> EventLoopFuture<[User]>
    func find(id: UUID?) -> EventLoopFuture<User?>
    func find(email: String) -> EventLoopFuture<User?>
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void> where Field: QueryableProperty, Field.Model == User
    func count() -> EventLoopFuture<Int>
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    let database: Database
    
    func create(_ user: User) -> EventLoopFuture<Void> {
        return user.create(on: database)
    }
    
    func delete(id: UUID) -> EventLoopFuture<Void> {
        return User.query(on: database)
            .filter(\.$id == id)
            .delete()
    }
    
    func all() -> EventLoopFuture<[User]> {
        return User.query(on: database).all()
    }
    
    func find(id: UUID?) -> EventLoopFuture<User?> {
        return User.find(id, on: database)
    }
    
    func find(email: String) -> EventLoopFuture<User?> {
        return User.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) -> EventLoopFuture<Void>
        where Field: QueryableProperty, Field.Model == User
    {
        return User.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }
    
    func count() -> EventLoopFuture<Int> {
        return User.query(on: database).count()
    }
}

extension Application.Repositories {
    var users: UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserRepository)) {
        storage.makeUserRepository = make
    }
}



