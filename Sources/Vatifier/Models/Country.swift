public enum Country: String, ExpressibleByStringLiteral {
    case austria = "AT"
    case belgium = "BE"
    case bulgaria = "BG"
    case croatia = "HR"
    case cyprus = "CY"
    case czechRepublic = "CZ"
    case denmark = "DK"
    case estonia = "EE"
    case finland = "FI"
    case france = "FR"
    case germany = "DE"
    case hungary = "HU"
    case ireland = "IE"
    case italy = "IT"
    case latvia = "LV"
    case lithuania = "LT"
    case luxembourg = "LU"
    case malta = "MT"
    case netherlands = "NL"
    case poland = "PL"
    case portugal = "PT"
    case romania = "RO"
    case slovakia = "SK"
    case slovenia = "SI"
    case spain = "ES"
    case sweden = "SE"
    case unitedKingdom = "GB"
    case invalid
    
    public init(stringLiteral value: String) {
        if let country = Country(rawValue: value) {
            self = country
        } else {
            self = .invalid
        }
    }
}


