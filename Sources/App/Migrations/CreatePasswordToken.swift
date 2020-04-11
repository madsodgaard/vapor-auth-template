import Fluent

struct CreatePasswordToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_password_tokens")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("token", .string, .required)
            .field("expires_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_password_tokens").delete()
    }
}
