import Vapor

protocol RequestService {
    func `for`(_ req: Request) -> Self
}
