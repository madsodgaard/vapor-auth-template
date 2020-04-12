import Vapor
import Queues

struct PasswordResetter {
    let queue: Queue
    let repository: PasswordTokenRepository
    let eventLoop: EventLoop
    let config: AppConfig
    let generator: RandomGenerator
    
    /// Sends a email to the user with a reset-password URL
    func reset(for user: User) -> EventLoopFuture<Void> {
        do {
            let token = generator.generate(bits: 256)
            let resetPasswordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash(token))
            let url = resetURL(for: token)
            let email = ResetPasswordEmail(resetURL: url)
            return repository.create(resetPasswordToken).flatMap {
                self.queue.dispatch(EmailJob.self, .init(email, to: user.email))
            }
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    private func resetURL(for token: String) -> String {
        "\(config.frontendURL)/auth/reset-password?token=\(token)"
    }
}

extension Request {
    var passwordResetter: PasswordResetter {
        .init(queue: self.queue, repository: self.passwordTokens, eventLoop: self.eventLoop, config: self.application.config, generator: self.application.random)
    }
}
