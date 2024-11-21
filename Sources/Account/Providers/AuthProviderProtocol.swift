import Foundation

public protocol AuthProviderProtocol {
    var isUserLoggedIn: Bool { get }
    var isUserEmailVerified: Bool { get }
    var userEmail: String? { get }
    var userId: String? { get }
    func createAccount(firstName: String, lastName: String, email: String, password: String) async -> Result<Void, Error>
    func deleteAccount() async -> Result<Bool, Error>
    func login(email: String, password: String) async -> Result<Bool, Error>
    func sendEmailVerification() async -> Result<Void, Error>
    func listenToEmailVerification(completion: @escaping () -> Void)
    func logout() -> Result<Void, Error>
    func resetPassword(email: String) async -> Result<Void, Error>
    func saveUserInfo(userInfo: UserInfo, completion: @escaping ((Error?) -> Void))
    func getUserInfo() async -> Result<UserInfo, Error>
}
