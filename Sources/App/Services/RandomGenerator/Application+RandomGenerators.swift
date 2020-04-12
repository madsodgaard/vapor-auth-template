import Vapor
import Crypto

public protocol RandomGenerator {
    func generate(bits: Int) -> String
}

extension Application {
    public struct RandomGenerators {
        public struct Provider {
            let run: ((Application) -> Void)
        }
        
        public let app: Application
        
        
        public func use(_ provider: Provider) {
            provider.run(app)
        }
        
        public func use(_ makeGenerator: @escaping ((Application) -> RandomGenerator)) {
            storage.makeGenerator = makeGenerator
        }
        
        final class Storage {
            var makeGenerator: ((Application) -> RandomGenerator)?
            init() {}
        }
        
        private struct Key: StorageKey {
            typealias Value = Storage
        }
        
        var storage: Storage {
            if let existing = self.app.storage[Key.self] {
                return existing
            } else {
                let new = Storage()
                self.app.storage[Key.self] = new
                return new
            }
        }
    }
    
    public var randomGenerators: RandomGenerators {
        .init(app: self)
    }
}
