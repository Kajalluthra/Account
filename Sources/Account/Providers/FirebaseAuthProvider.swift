import FirebaseAuth
import FirebaseDatabase
import os
import LoggerExtension

struct FirebaseAuthProvider: AuthProviderProtocol {

    let USERS_TABLE = "Users"

    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    var isUserEmailVerified: Bool {
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }

    var userEmail: String? {
        return Auth.auth().currentUser?.email
    }

    var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    func createAccount(firstName: String, lastName: String, email: String, password: String) async -> Result<Void, Error> {
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            let userInfo = UserInfo(email: email, firstName: firstName, lastName: lastName)
            self.saveUserInfo(userInfo: userInfo, completion: {_ in})
            return .success(())
        } catch {
            Logger.service.log(level: .error, message: "Error creating user: \(error.localizedDescription)")
            guard let errCode = AuthErrorCode.Code(rawValue: error._code) else {
                return .failure(error)
            }
            switch errCode {
            case .emailAlreadyInUse:
                return .failure(AccountError.emailAlreadyInUse)
            default:
                return .failure(error)
            }
        }
    }

    func deleteAccount() async -> Result<Bool, Error> {
        do {
            try await Auth.auth().currentUser?.delete()
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    func login(email: String, password: String) async -> Result<Bool, Error> {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = authDataResult.user
            Logger.service.log(level: .info, message: "Signed in user: \(user.email ?? "no email")")
            return .success(user.isEmailVerified)
        } catch {
            Logger.service.log(level: .error, message: "Error signing in user: \(error.localizedDescription)")
            guard let errCode = AuthErrorCode.Code(rawValue: error._code) else {
                return .failure(error)
            }
            switch errCode {
            case .wrongPassword, .userNotFound:
                return .failure(AccountError.invalidCredentials)
            default:
                return .failure(error)
            }
        }
    }

    func sendEmailVerification() async -> Result<Void, Error> {
        do {
            try await Auth.auth().currentUser?.sendEmailVerification()
            Logger.service.log(level: .info, message: "Email verification sent successfully")
            return .success(())
        } catch {
            Logger.service.log(level: .error, message: "Error sending email verification: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func listenToEmailVerification(completion: @escaping () -> Void) {
        // TODO: Not good approach but Firebase doesn't notify about email verification status changes. For a POC is fine
        Auth.auth().currentUser?.reload()
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            completion()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                listenToEmailVerification(completion: completion)
            }
        }
    }

    func logout() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            Logger.service.log(level: .info, message: "User logged out")
            return .success(())
        } catch {
            Logger.service.log(level: .error, message: "Error logging out user: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func resetPassword(email: String) async -> Result<Void, Error> {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            Logger.service.log(level: .info, message: "Password reset email sent successfully")
            return .success(())
        } catch {
            Logger.service.log(level: .error, message: "Error sending password reset email: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func saveUserInfo(userInfo: UserInfo, completion: @escaping ((Error?) -> Void)) {
        guard let userId = Auth.auth().currentUser?.uid else { return completion(AccountError.userNotFound)}
        let reference = Database.database(url: Config.databaseURL).reference().child(USERS_TABLE).child(userId)

        reference.setValue(userInfo.dictionary) { error, _ in
            guard error == nil else {
                return completion(AccountError.errorSavingData)
            }
            completion(nil)
        }
    }

    func getUserInfo() async -> Result<UserInfo, Error> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return .failure(AccountError.userNotFound)
        }
        let reference = Database.database(url: Config.databaseURL).reference().child(USERS_TABLE).child(userId)
        do {
            let value = try await reference.getData().value
            let dictionary = value as? NSDictionary
            let userInfo = UserInfo(data: dictionary ?? [:])
            return .success(userInfo)
        } catch {
            return .failure(error)
        }
    }
}
