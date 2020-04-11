import Vapor
import Fluent

final class User: Model, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "full_name")
    var fullName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    @Field(key: "is_email_verified")
    var isEmailVerified: Bool
    
    init() {}
    
    init(
        id: UUID? = nil,
        fullName: String,
        email: String,
        passwordHash: String,
        isAdmin: Bool = false,
        isEmailVerified: Bool = false
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.isEmailVerified = isEmailVerified
    }
    
    /// Generates a 256-bit refresh token.
    func generateRefreshToken(generator: RandomGenerator) throws -> RefreshToken {
        try RefreshToken(token: generator.generate(bits: 256), userID: self.requireID())
    }
    
    /// Generates a UUID password reset token
    func generateResetPasswordToken(generator: RandomGenerator) throws -> PasswordToken {
        try PasswordToken(userID: self.requireID(), token: generator.generate(bits: 256))
    }
    
    /// Generates a UUID email verification token
    func generateEmailToken(generator: RandomGenerator) throws -> EmailToken {
        try EmailToken(userID: self.requireID(), token: generator.generate(bits: 256))
    }
}
