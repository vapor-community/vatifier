import Vapor

extension Application.Vatifier {
    public func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse {
        try await self.client.verify(vatNumber, country: country)
    }
}
