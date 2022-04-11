import Vapor

public protocol VatifierClient {
    func hopped(to eventLoop: EventLoop) -> VatifierClient
    func verify(_ vatNumber: String, country: Country) -> EventLoopFuture<VATVerificationResponse>
    func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse
}
