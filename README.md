# Vatifier

![Swift](http://img.shields.io/badge/swift-5.2-brightgreen.svg)
![Vapor](http://img.shields.io/badge/vapor-4.0-brightgreen.svg)

### Vatifier is a Vapor helper for verifying VAT numbers via the [VIES service](https://ec.europa.eu/taxation_customs/vies/)

## Usage
Add the following line to your `Package.swift`
~~~~swift
.package(url: "https://github.com/vapor-community/vatifier.git", from: "1.0.0")

.product(name: "Vatifier", package: "vatifier")
~~~~

Add this line to your `configure.swift` file:
~~~~swift
import Vatifier

app.vatifier.use(.VIES)
~~~~

You can now verify VAT numbers from `Application` or `Request`
~~~~swift
app.vatifier.verify("47458714", country: "DK")
req.vatifier.verify("47458714", country: "DK")
~~~~

If the API request was successfull you will have a `VATVerificationResponse` which contains an `isValid` boolean and optional `name` and `address` properties. If the API request failed, the future will be in an error state and a `VIESError` will be returned.
