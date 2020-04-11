import XCTVapor
@testable import App
import Mailgun

struct MockMailgun: MailgunProvider {
    var eventLoop: EventLoop
    
    func send(_ content: MailgunMessage) -> EventLoopFuture<ClientResponse> {
        fatalError()
    }
    
    func send(_ content: MailgunTemplateMessage) -> EventLoopFuture<ClientResponse> {
        fatalError()
    }
    
    func setup(forwarding: MailgunRouteSetup) -> EventLoopFuture<ClientResponse> {
        fatalError()
    }
    
    func createTemplate(_ template: MailgunTemplate) -> EventLoopFuture<ClientResponse> {
        fatalError()
    }
    
    func delegating(to eventLoop: EventLoop) -> MailgunProvider {
        var copy = self
        copy.eventLoop = eventLoop
        return copy
    }
}

extension Application.Mailgun.Provider {
    static var fake: Self {
        .init {
            $0.mailgun.use { app, _ in
                MockMailgun(eventLoop: app.eventLoopGroup.next())
            }
        }
    }
}
