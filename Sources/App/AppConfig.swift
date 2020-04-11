import Vapor

struct AppConfig {
    let frontendURL: String
    let apiURL: String
    let noReplyEmail: String
    
    static var environment: AppConfig {
        guard
            let frontendURL = Environment.get("SITE_FRONTEND_URL"),
            let apiURL = Environment.get("SITE_API_URL"),
            let noReplyEmail = Environment.get("NO_REPLY_EMAIL")
            else {
                fatalError("Please add app configuration to environment variables")
        }
        
        return .init(frontendURL: frontendURL, apiURL: apiURL, noReplyEmail: noReplyEmail)
    }
}

extension Application {
    struct AppConfigKey: StorageKey {
        typealias Value = AppConfig
    }
    
    var config: AppConfig {
        get {
            storage[AppConfigKey.self] ?? .environment
        }
        set {
            storage[AppConfigKey.self] = newValue
        }
    }
}
