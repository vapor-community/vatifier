import Vapor

extension Application {
    public var vatifier: Vatifier {
        .init(app: self)
    }
    
    public struct Vatifier {
        let app: Application
        
        init(app: Application) {
            self.app = app
        }
        
        public struct Provider {
            public static func VIES(environment: VIESClient.Environment) -> Self {
                .init {
                    $0.vatifier.use {
                        VIESClient(client: $0.client, environment: environment)
                    }
                }
            }
            
            public static var VIES: Self {
                .VIES(environment: .production)
            }
            
            let run: ((Application) -> Void)
            
            public init(_ run: @escaping ((Application) -> Void)) {
                self.run = run
            }
        }
        
        private final class Storage {
            var make: ((Application) -> VatifierClient)?
            init() { }
        }
        
        private struct Key: StorageKey {
            typealias Value = Storage
        }
        
        private var storage: Storage {
            if app.storage[Key.self] == nil {
                app.storage[Key.self] = .init()
            }
            
            return app.storage[Key.self]!
        }
        
        var client: VatifierClient {
            guard let makeClient = storage.make else {
                fatalError("Vatifier not configured, use: app.vatifier.use(.VIES)")
            }
            
            return makeClient(app)
        }
        
        public func use(_ factory: @escaping ((Application) -> VatifierClient)) {
            self.storage.make = factory
        }
        
        public func use(_ provider: Provider) {
            provider.run(app)
        }
    }
}

extension Application.Vatifier: VatifierClient {
    public func hopped(to eventLoop: EventLoop) -> VatifierClient {
        self.client.hopped(to: eventLoop)
    }
    
    public func verify(_ vatNumber: String, country: Country) -> EventLoopFuture<VATVerificationResponse> {
        self.client.verify(vatNumber, country: country)
    }
    
    public func verify(_ vatNumber: String, country: Country) async throws -> VATVerificationResponse {
        try await self.client.verify(vatNumber, country: country)
    }
}

extension Request {
    public var vatifier: VatifierClient {
        application.vatifier.client.hopped(to: self.eventLoop)
    }
}
