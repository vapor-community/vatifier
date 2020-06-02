import Vapor

public struct VATVerificationResponse: Content {
    public let isValid: Bool
    public let name: String?
    public let address: String?
}
