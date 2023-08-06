import Fluent
import FluentPostgresDriver
import Vapor
import JWT
import Mailgun
import QueuesRedisDriver

public func configure(_ app: Application) throws {
    // MARK: JWT
    if app.environment != .testing {
        let jwksFilePath = app.directory.workingDirectory + (Environment.get("JWKS_KEYPAIR_FILE") ?? "keypair.jwks")
         guard
             let jwks = FileManager.default.contents(atPath: jwksFilePath),
             let jwksString = String(data: jwks, encoding: .utf8)
             else {
                 fatalError("Failed to load JWKS Keypair file at: \(jwksFilePath)")
         }
         try app.jwt.signers.use(jwksJSON: jwksString)
    }
    
    // MARK: Database
    // Configure PostgreSQL database
    
    try configurePostgres(for:app)
    
    // MARK: Middleware
    app.middleware = .init()
    app.middleware.use(ErrorMiddleware.custom(environment: app.environment))
    
    // MARK: Model Middleware
    
    // MARK: Mailgun
    app.mailgun.configuration = .environment
    app.mailgun.defaultDomain = .sandbox
    
    // MARK: App Config
    app.config = .environment
    
    try routes(app)
    try migrations(app)
    try queues(app)
    try services(app)
    
    
    if app.environment == .development {
        try app.autoMigrate().wait()
        try app.queues.startInProcessJobs()
    }
}

fileprivate func configurePostgres(for app:Application)  throws {
    
    let host = Environment.get("POSTGRES_HOSTNAME") ?? "localhost"
    let user =  Environment.get("POSTGRES_USERNAME") ?? "vapor"
    let password = Environment.get("POSTGRES_PASSWORD") ?? "password"
    let db =  Environment.get("POSTGRES_DATABASE") ?? "vapor"
    
    let port = Environment.get("DATABASE_PORT")
               .flatMap(Int.init(_:)) ??
                SQLPostgresConfiguration.ianaPortNumber
    /**
        Postgresql URL Format
     
     postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]
     */
        
    let url = "postgresql://\(user):\(password)@\(host):\(port)/\(db)"
    
    try app.databases.use(.postgres(url: url),
                          as: .psql)
}
