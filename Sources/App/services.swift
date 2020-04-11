import Vapor

func services(_ app: Application) throws {
    app.randomGenerators.use(.random)
    app.repositories.use(.database)
}
