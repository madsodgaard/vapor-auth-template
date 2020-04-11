@testable import App
import XCTVapor

extension Application {
    // Authenticated test method
    @discardableResult
    func test<C: Content>(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        accessToken: String? = nil,
        user: User? = nil,
        content: C,
        afterResponse: (XCTHTTPResponse) throws -> () = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> XCTApplicationTester {
        var headers = headers
        
        if let token = accessToken {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        } else if let user = user {
            let payload = try Payload(with: user)
            let accessToken = try self.jwt.signers.sign(payload)
            
            headers.add(name: "Authorization", value: "Bearer \(accessToken)")
        }
        
        return try test(method, path, headers: headers, beforeRequest: { req in
            try req.content.encode(content)
        }, afterResponse: afterResponse)
    }
    
    @discardableResult
    func test(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        user: User,
        afterResponse: (XCTHTTPResponse) throws -> () = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> XCTApplicationTester {
        let payload = try Payload(with: user)
        let accessToken = try self.jwt.signers.sign(payload)
        var headers = headers
        headers.add(name: "Authorization", value: "Bearer \(accessToken)")
        return try test(method, path, headers: headers, afterResponse: afterResponse)
    }
}
