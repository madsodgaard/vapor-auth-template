import Vapor

struct AccessTokenResponse: Content {
    let refreshToken: String
    let accessToken: String
}
