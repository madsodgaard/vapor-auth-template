import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("full_name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("is_admin", .bool, .required, .custom("DEFAULT FALSE"))
            .field("is_email_verified", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
