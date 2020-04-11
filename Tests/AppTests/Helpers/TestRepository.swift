@testable import App
import Vapor

protocol TestRepository: class {
    var eventLoop: EventLoop { get set }
}

extension TestRepository where Self: RequestService {
    func `for`(_ req: Request) -> Self {
        self.eventLoop = req.eventLoop
        return self
    }
}
