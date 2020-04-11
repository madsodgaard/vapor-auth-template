import Vapor

struct SendEmailVerificationRequest: Content {
    let email: String
}
