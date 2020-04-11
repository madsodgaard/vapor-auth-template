import XCTVapor
@testable import App

func XCTAssertResponseError(_ res: XCTHTTPResponse, _ error: AppError, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(res.status, error.status, file: file, line: line)
    XCTAssertContent(ErrorResponse.self, res) { errorContent in
        XCTAssertEqual(errorContent.errorCode, error.identifier, file: file, line: line)
        XCTAssertEqual(errorContent.reason, error.reason, file: file, line: line)
    }
}
