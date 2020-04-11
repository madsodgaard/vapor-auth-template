import Vapor

extension Application {
    public var random: AppRandomGenerator {
        .init(app: self)
    }
    
    public struct AppRandomGenerator: RandomGenerator {
        let app: Application
        
        var generator: RandomGenerator {
            guard let makeGenerator = app.randomGenerators.storage.makeGenerator else {
                fatalError("randomGenerators not configured, please use: app.randomGenerators.use")
            }
            
            return makeGenerator(app)
        }
        
        public func generate(bits: Int) -> String {
            generator.generate(bits: bits)
        }
    }
}
