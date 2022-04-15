import Vapor

extension VatifierClient {
    func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse {
        try await verify(vatNumber, country: country).get()
    }
}
