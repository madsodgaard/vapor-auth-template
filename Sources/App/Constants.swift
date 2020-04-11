struct Constants {
    /// How long should access tokens live for. Default: 15 minutes (in seconds)
    static let ACCESS_TOKEN_LIFETIME: Double = 60 * 15
    /// How long should refresh tokens live for: Default: 7 days (in seconds)
    static let REFRESH_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 7
    /// How long should the email tokens live for: Default 24 hours (in seconds)
    static let EMAIL_TOKEN_LIFETIME: Double = 60 * 60 * 24
    /// Lifetime of reset password tokens: Default 1 hour (seconds)
    static let RESET_PASSWORD_TOKEN_LIFETIME: Double = 60 * 60
}
