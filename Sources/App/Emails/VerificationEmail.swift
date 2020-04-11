import Vapor

struct VerificationEmail: Email {
    let templateName: String = "email_verification"
    let verifyUrl: String
    
    var subject: String {
        "Please verify your email"
    }
    
    var templateData: [String : String] {
        ["verify_url": verifyUrl]
    }
    
    init(verifyUrl: String) {
        self.verifyUrl = verifyUrl
    }
}
