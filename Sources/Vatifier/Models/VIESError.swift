import Vapor

public enum VIESError: DebuggableError, Equatable {
    case failedToParseResponse
    case invalidInput
    case serviceUnavailable
    case msUnavailable
    case msMaxConcurrentRequests
    case timeout
    case serverBusy
    case invalidRequesterInfo
    case unknown(String)
    
    public var identifier: String {
        switch self {
        case .failedToParseResponse:
            return "failedToParseReponse"
        case .invalidInput:
            return "invalidInput"
        case .serviceUnavailable:
            return "serviceUnavailable"
        case .msUnavailable:
            return "msUnavailable"
        case .msMaxConcurrentRequests:
            return "msMaxConcurrentRequests"
        case .timeout:
            return "timeout"
        case .serverBusy:
            return "serverBusy"
        case .invalidRequesterInfo:
            return "invalidRequesterInfo"
        case .unknown(let fault):
            return fault
        }
    }
    
    public var reason: String {
        switch self {
        case .failedToParseResponse:
            return "Failed to parse the XML response from VIES"
        case .invalidInput:
            return "The provided CountryCode is invalid or the VAT number is empty"
        case .serviceUnavailable:
            return "The VIES VAT service is unavailable, please try again later"
        case .msUnavailable:
            return "The VAT database of the requested member country is unavailable, please try again later"
        case .msMaxConcurrentRequests:
            return "The VAT database of the requested member country has had too many requests, please try again later"
        case .timeout:
            return "The request to VAT database of the requested member country has timed out, please try again later"
        case .serverBusy:
            return "The service cannot process your request, please try again later"
        case .invalidRequesterInfo:
            return "The requester info is invalid"
        case .unknown(let fault):
            return "Unknown error from VIES, fault string: \(fault)"
        }
    }
    
    init(faultString: String) {
        switch faultString {
        case "INVALID_INPUT":
            self = .invalidInput
        case "SERVICE_UNAVAILABLE":
            self = .serviceUnavailable
        case "MS_UNAVAILABLE":
            self = .msUnavailable
        case "MS_MAX_CONCURRENT_REQ":
            self = .msMaxConcurrentRequests
        case "TIMEOUT":
            self = .timeout
        case "SERVER_BUSY":
            self = .serverBusy
        case "INVALID_REQUESTER_INFO":
            self = .invalidRequesterInfo
        default:
            self = .unknown(faultString)
        }
    }
}
