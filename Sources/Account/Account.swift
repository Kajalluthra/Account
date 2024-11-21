import Foundation

public final class Account {
    
    public static func setup(with config: AccountConfig.Type) {
        ConfigType.shared = ConfigType(config)
    }

    public static func authProvider() -> AuthProviderProtocol {
        return FirebaseAuthProvider()
    }
}
