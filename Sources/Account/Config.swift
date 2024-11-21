import Foundation

public protocol AccountConfig {
    static var databaseURL: String { get }
}

var Config: ConfigType { // swiftlint:disable:this variable_name
    if let config = ConfigType.shared {
        return config
    } else {
        fatalError("Please set the Config for \(Bundle(for: ConfigType.self))")
    }
}

final class ConfigType {
    
    static var shared: ConfigType?
    
    let databaseURL: String
    
    init(_ config: AccountConfig.Type) {
        self.databaseURL = config.databaseURL
    }
    
}
