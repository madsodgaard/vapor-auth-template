import Vapor
import Queues
import Mailgun

struct EmailPayload: Codable {
    let email: AnyEmail
    let recipient: String
    
    init<E: Email>(_ email: E, to recipient: String) {
        self.email = AnyEmail(email)
        self.recipient = recipient
    }
}

struct EmailJob: Job {
    typealias Payload = EmailPayload
    
    func dequeue(_ context: QueueContext, _ payload: EmailPayload) -> EventLoopFuture<Void> {
        let mailgunMessage = MailgunTemplateMessage(
            from: context.appConfig.noReplyEmail,
            to: payload.recipient,
            subject: payload.email.subject,
            template: payload.email.templateName,
            templateData: payload.email.templateData
        )
        
        return context.mailgun().send(mailgunMessage).transform(to: ())
    }
}

