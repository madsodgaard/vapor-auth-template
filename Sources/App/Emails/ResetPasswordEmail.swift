import Vapor

struct ResetPasswordEmail: Email {
    let templateName: String = "reset_password"
    var templateData: [String : String] {
        ["reset_url": resetURL]
    }
    var subject: String {
        "Reset your password"
    }
    
    let resetURL: String
    
    init(resetURL: String) {
        self.resetURL = resetURL
    }
}

