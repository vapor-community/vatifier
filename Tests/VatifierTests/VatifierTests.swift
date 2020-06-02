import XCTest
import XCTVapor
import Vatifier

final class VatifierTests: XCTestCase {
    var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
    }
    
    func testValidVATNumber() throws {
        app.vatifier.use(.VIES)
        let result = try app.vatifier.verify("47458714", country: "DK").wait()
        XCTAssertTrue(result.isValid)
    }
    
    func testInvalidVATNumber() throws {
        app.vatifier.use(.VIES)
        let result = try app.vatifier.verify("123", country: .denmark).wait()
        XCTAssertFalse(result.isValid)
        XCTAssertNil(result.name)
        XCTAssertNil(result.address)
    }
    
    func testInvalidCountry() throws {
        app.vatifier.use(.VIES)
        XCTAssertThrowsError(try app.vatifier.verify("47458714", country: "ASDF").wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.invalidInput)
        }
    }
    
    func testVIESReturnsInvalidInput() throws {
        app.vatifier.use(.VIES(environment: .testing))
        
        XCTAssertThrowsError(try app.vatifier.verify("201", country: .denmark).wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.invalidInput)
        }
    }
    
    func testVIESReturnsInvalidRequesterInfo() throws {
        app.vatifier.use(.VIES(environment: .testing))
        
        XCTAssertThrowsError(try app.vatifier.verify("202", country: .denmark).wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.invalidRequesterInfo)
        }
    }
    
    func testVIESReturnsServiceUnavailable() throws {
        app.vatifier.use(.VIES(environment: .testing))
        
        XCTAssertThrowsError(try app.vatifier.verify("300", country: .denmark).wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.serviceUnavailable)
        }
    }
    
    func testVIESReturnsMSUnavailable() throws {
        app.vatifier.use(.VIES(environment: .testing))
        
        XCTAssertThrowsError(try app.vatifier.verify("301", country: .denmark).wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.msUnavailable)
        }
    }
    
    func testVIESReturnsTimeout() throws {
        app.vatifier.use(.VIES(environment: .testing))
        
        XCTAssertThrowsError(try app.vatifier.verify("302", country: .denmark).wait(), "") { error in
            XCTAssertEqual(error as? VIESError, VIESError.timeout)
        }
    }
}
