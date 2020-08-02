import Vapor

public struct VATVerificationResponse: Content {
    public let isValid: Bool
    public let name: String?
    public let address: String?
    
    public init(isValid: Bool, name: String? = nil, address: String? = nil) {
        self.isValid = isValid
        self.name = name
        self.address = address
    }
}
