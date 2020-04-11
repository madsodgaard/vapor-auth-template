import Fluent
import Queues

extension QueueContext {
    var db: Database {
        application.databases
            .database(logger: self.logger, on: self.eventLoop)!
    }
}
