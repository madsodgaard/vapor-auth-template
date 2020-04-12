import Crypto
import Foundation

extension SHA256Digest {
    var base64: String {
        Data(self).base64EncodedString()
    }
    
    var base64URLEncoded: String {
        Data(self).base64URLEncodedString()
    }
}
