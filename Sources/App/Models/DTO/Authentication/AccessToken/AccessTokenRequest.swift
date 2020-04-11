import Vapor

struct AccessTokenRequest: Content {
    let refreshToken: String
}
