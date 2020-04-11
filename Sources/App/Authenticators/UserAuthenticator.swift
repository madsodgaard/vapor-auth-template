import Vapor
import JWT

struct UserAuthenticator: JWTAuthenticator {
    typealias Payload = App.Payload
    
    func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
        request.auth.login(jwt)
        return request.eventLoop.makeSucceededFuture(())
    }
}
