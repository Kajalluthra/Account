import Foundation

public enum AccountError: String, Error {
    case invalidCredentials
    case emailAlreadyInUse
    case userNotFound
    case errorSavingData
    case invalidDataFormat
}
