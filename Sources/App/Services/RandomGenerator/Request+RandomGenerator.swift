import Vapor

extension Request {
    var random: RandomGenerator {
        self.application.random
    }
}
