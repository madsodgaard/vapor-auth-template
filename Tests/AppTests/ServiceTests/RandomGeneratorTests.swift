@testable import App
import XCTVapor

final class RandomGeneratorTests: XCTestCase {
    var app: Application!
    var testWorld: TestWorld!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        testWorld = try .init(app: app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testDefaultProvider() throws {
        let defaultGenerator = app.random.generator
        XCTAssertTrue(type(of: defaultGenerator) == RealRandomGenerator.self)
    }
}
