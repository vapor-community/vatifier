import Vapor
import SwiftyXMLParser

public struct VIESClient: VatifierClient {
    public enum Environment {
        case production
        case testing
        
        var apiURL: String {
            switch self {
            case .production:
                return "https://ec.europa.eu/taxation_customs/vies/services/checkVatService"
            case .testing:
                return "https://ec.europa.eu/taxation_customs/vies/services/checkVatTestService"
            }
        }
    }
    
    private let client: Client
    private let environment: Environment
    private let headers = HTTPHeaders([
        ("Content-Type", "application/xml"),
        ("Cache-Control", "no-cache")
    ])
    
    init(client: Client, environment: Environment) {
        self.client = client
        self.environment = environment
    }
    
    public func hopped(to eventLoop: EventLoop) -> VatifierClient {
        VIESClient(client: self.client.delegating(to: eventLoop), environment: self.environment)
    }
    
    public func verify(_ vatNumber: String, country: Country) -> EventLoopFuture<VATVerificationResponse> {
        guard country != .invalid else {
            return client.eventLoop.future(error: VIESError.invalidInput)
        }
        
        let request = prepareRequest(by: vatNumber, country: country)
        
        return client.send(request)
            .flatMap { response in
                let result = validateVerifying(response: response)
                
                guard result.error == nil else {
                    return self.client.eventLoop.future(error: result.error!)
                }
                
                guard let response = result.response else {
                    return self.client.eventLoop.future(error: VIESError(faultString: ""))
                }
                
                return self.client.eventLoop.future(response)
        }
    }
    
    public func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse {
        guard country != .invalid else {
            throw VIESError.invalidInput
        }
        
        let request = prepareRequest(by: vatNumber, country: country)
        
        let result = validateVerifying(response: try await client.send(request))
        
        guard result.error == nil else {
            throw result.error!
        }
        
        guard let response = result.response else {
            throw VIESError(faultString: "")
        }
        
        return response
    }
    
    private func prepareRequest(by vatNumber: String, country: Country) -> ClientRequest {
        let soapBody = VIESClient.soapBodyTemplate
            .replacingOccurrences(of: "%COUNTRY%", with: country.rawValue)
            .replacingOccurrences(of: "%VATNUMBER%", with: vatNumber)
        
        var buffer = ByteBufferAllocator().buffer(capacity: soapBody.utf8.count)
        buffer.writeString(soapBody)
        
        return ClientRequest(method: .POST, url: URI(string: environment.apiURL), headers: headers, body: buffer)
    }
    
    private func validateVerifying(response: ClientResponse) -> (response: VATVerificationResponse?, error: VIESError?) {
        guard let buffer = response.body else {
            return (response: nil, error: VIESError.failedToParseResponse)
        }
        
        do {
            let responseXML = try XML.parse(String(buffer: buffer))
            
            if let faultString = responseXML["soap:Envelope", "soap:Body", "soap:Fault", "faultstring"].text {
                return (response: nil, error: VIESError(faultString: faultString))
            }
            
            let fields = responseXML["soap:Envelope", "soap:Body", "checkVatResponse"]
            
            guard
                let isValidString = fields["valid"].text,
                let isValid = Bool(isValidString)
                else {
                return (response: nil, error: VIESError.failedToParseResponse)
            }
            
            var address: String? = nil
            var name: String? = nil
            
            if let xmlName = fields["name"].text, xmlName != "---" {
                name = xmlName
            }
            
            if let xmlAddress = fields["address"].text, xmlAddress != "---" {
                address = xmlAddress
            }
            
            return (response: VATVerificationResponse(isValid: isValid, name: name, address: address), error: nil)
        } catch XMLError.failToEncodeString {
            return (response: nil, error: VIESError.failedToParseResponse)
        } catch {
            return (response: nil, error: VIESError(faultString: error.localizedDescription))
        }
    }
}

extension VIESClient {
    static let soapBodyTemplate = """
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns1="urn:ec.europa.eu:taxud:vies:services:checkVat:types" xmlns:impl="urn:ec.europa.eu:taxud:vies:services:checkVat">
        <soap:Header></soap:Header>
        <soap:Body>
            <tns1:checkVat xmlns:tns1="urn:ec.europa.eu:taxud:vies:services:checkVat:types"     xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">     <tns1:countryCode>%COUNTRY%</tns1:countryCode>
                <tns1:vatNumber>%VATNUMBER%</tns1:vatNumber>
            </tns1:checkVat>
        </soap:Body>
    </soap:Envelope>
    """
}
