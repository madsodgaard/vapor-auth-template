import Crypto


extension SHA256 {
    static func hash(_ string: String) -> String {
        SHA256.hash(data: string.data(using: .utf8)!).base64
    }
}
