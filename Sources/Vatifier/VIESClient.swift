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
        
        let soapBody = VIESClient.soapBodyTemplate
            .replacingOccurrences(of: "%COUNTRY%", with: country.rawValue)
            .replacingOccurrences(of: "%VATNUMBER%", with: vatNumber)
        
        var buffer = ByteBufferAllocator().buffer(capacity: soapBody.utf8.count)
        buffer.writeString(soapBody)
        
        let headers = HTTPHeaders([
            ("Content-Type", "application/xml"),
            ("Cache-Control", "no-cache")
        ])
        
        let request = ClientRequest(method: .POST, url: URI(string: environment.apiURL), headers: headers, body: buffer)
        
        return client.send(request)
            .flatMap { response in
                guard let buffer = response.body else {
                    return self.client.eventLoop.future(error: VIESError.failedToParseResponse)
                }
                
                do {
                    let responseXML = try XML.parse(String(buffer: buffer))
                    
                    if let faultString = responseXML["soap:Envelope", "soap:Body", "soap:Fault", "faultstring"].text {
                        return self.client.eventLoop.future(error: VIESError(faultString: faultString))
                    }
                    
                    let fields = responseXML["soap:Envelope", "soap:Body", "checkVatResponse"]
                    
                    guard
                        let isValidString = fields["valid"].text,
                        let isValid = Bool(isValidString)
                        else {
                            return self.client.eventLoop.future(error: VIESError.failedToParseResponse)
                    }
                    
                    var address: String? = nil
                    var name: String? = nil
                    
                    if let xmlName = fields["name"].text, xmlName != "---" {
                        name = xmlName
                    }
                    
                    if let xmlAddress = fields["address"].text, xmlAddress != "---" {
                        address = xmlAddress
                    }
                    
                    return self.client.eventLoop.future(VATVerificationResponse(isValid: isValid, name: name, address: address))
                } catch XMLError.failToEncodeString {
                    return self.client.eventLoop.future(error: VIESError.failedToParseResponse)
                } catch {
                    return self.client.eventLoop.future(error: error)
                }
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
