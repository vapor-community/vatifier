import Vapor

extension VatifierClient {
    public func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse {
        try await verify(vatNumber, country: country).get()
    }
}
