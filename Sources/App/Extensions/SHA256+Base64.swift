import Crypto

extension SHA256Digest {
    var base64: String {
        Array(self).hex.data(using: .utf8)!.base64EncodedString()
    }
}
