import Foundation
import OrderedCollections

public struct UserInfo: Equatable {

    public var firstName: String
    public var lastName: String
    public var email: String
    public var address: String
    public var railcard: String
    public var photocard: String

    var dictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        return Dictionary(uniqueKeysWithValues: mirror.children.compactMap { child in
            guard let label = child.label else { return nil }
            return (label, child.value)
        })
    }

    public var orderedDictionary: OrderedDictionary<String, Any> {
        let mirror = Mirror(reflecting: self)
        return OrderedDictionary(uniqueKeysWithValues: mirror.children.compactMap { child in
            guard let label = child.label else { return nil }
            return (label, child.value)
        })
    }

    public init(email: String, firstName: String, lastName: String, address: String = "", railcard: String = "", photocard: String = "") {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.railcard = railcard
        self.photocard = photocard
    }

    public init(data: NSDictionary) {
        self.email = data["email"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.railcard = data["railcard"] as? String ?? ""
        self.photocard = data["photocard"] as? String ?? ""
    }
}
