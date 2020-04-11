import XCTVapor
@testable import App
import Mailgun

struct MockMailgun: MailgunProvider {
    var eventLoop: EventLoop
    
    func send(_ content: MailgunMessage) -> EventLoopFuture<HTTPClient.Response> {
        fatalError()
    }
    
    func send(_ content: MailgunTemplateMessage) -> EventLoopFuture<HTTPClient.Response> {
        fatalError()
    }
    
    func setup(forwarding: MailgunRouteSetup) -> EventLoopFuture<HTTPClient.Response> {
        fatalError()
    }
    
    func createTemplate(_ template: MailgunTemplate) -> EventLoopFuture<HTTPClient.Response> {
        fatalError()
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
