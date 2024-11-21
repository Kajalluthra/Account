import XCTest
@testable import Account
@testable import FirebaseAuth

class FirebaseAuthProviderTests: XCTestCase {
    private var accountProvider: FirebaseAuthProvider!

    override func setUp() {
        super.setUp()
        accountProvider = FirebaseAuthProvider()
    }

    override func tearDown() {
        _ = accountProvider.logout()
        accountProvider = nil
        super.tearDown()
    }

    func testLogin_WithCorrectCredentials_ShouldReturnSuccessfulLogin() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        switch result {
        case .success:
            XCTAssert(true)
        case .failure(let error):
            XCTFail("Login failed with error: \(error)")
        }
    }

    func testLogin_WithNonExistentEmail_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "noexist@noexist.com", password: "123456")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.invalidCredentials)
        }
    }

    func testLogin_WithIncorrectPassword_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "1234567")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.invalidCredentials)
        }
    }

    func testLogin_WithEmptyEmail_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "", password: "123456")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "The email address is badly formatted.")
        }
    }

    func testLogin_WithEmptyPassword_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.invalidCredentials)
        }
    }

    func testLogin_WithEmptyEmailAndPassword_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "", password: "")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.invalidCredentials)
        }
    }

    func testLogin_WithInvalidEmail_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "miguel.morales", password: "123456")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "The email address is badly formatted.")
        }
    }

    func testLogin_WithInvalidPassword_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "12345")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.invalidCredentials)
        }
    }

    func testLogin_WithInvalidEmailAndPassword_ShouldReturnError() async throws {
        let result = await accountProvider.login(email: "miguel.morales", password: "12345")
        switch result {
        case .success:
            XCTFail("Login should not succeed")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "The email address is badly formatted.")
        }
    }

    func _testSendEmailVerification_WithCorrectCredentials_ShouldReturnSuccess() async throws {
        await _ = accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        let result = await accountProvider.sendEmailVerification()
        switch result {
        case .success:
            XCTAssert(true)
        case .failure(let error):
            XCTFail("Verification failed with error: \(error)")
        }
    }

    func testLogout_ShouldReturnSuccess() async throws {
        await _ = accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        let result = accountProvider.logout()
        switch result {
        case .success:
            XCTAssertNil(Auth.auth().currentUser)
        case .failure(let error):
            XCTFail("Logout failed with error: \(error)")
        }
    }

    func _testResetPassword_WithCorrectCredentials_ShouldReturnSuccess() async throws {
        let result = await accountProvider.resetPassword(email: "miguel.morales@srt.com")
        switch result {
        case .success:
            XCTAssert(true)
        case .failure(let error):
            XCTFail("Reset password failed with error: \(error)")
        }
    }

    func testResetPassword_WithInvalidEmail_ShouldReturnError() async throws {
        let result = await accountProvider.resetPassword(email: "miguel.moral@silverrailtech.com")
        switch result {
        case .success:
            XCTFail("Reset password should not succeed")
        case .failure:
            XCTAssert(true)
        }
    }

    func testIsLoggedIn_WithCorrectCredentials_ShouldReturnTrue() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        switch result {
        case .success:
            XCTAssertTrue(accountProvider.isUserLoggedIn)
        case .failure(let error):
            XCTFail("Login failed with error: \(error)")
        }
    }

    func testGetUserEmail_WithCorrectCredentials_ShouldReturnEmail() async throws {
        let result = await accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        switch result {
        case .success:
            XCTAssertEqual(accountProvider.userEmail, "miguel.morales@srt.com")
        case .failure(let error):
            XCTFail("Login failed with error: \(error)")
        }
    }

    func testCreateAccount_WithCorrectCredentials_ShouldReturnSuccess() async throws {
        _ = await accountProvider.login(email: "example@example.com", password: "example")
        _ = await accountProvider.deleteAccount()
        let result = await accountProvider.createAccount(firstName: "example", lastName: "example", email: "example@example.com", password: "example")
        switch result {
        case .success:
            XCTAssert(true)
        case .failure(let error):
            XCTFail("Create account failed with error: \(error)")
        }
    }

    func testCreateAccount_WithExistentEmail_ShouldReturnError() async throws {
        let result = await accountProvider.createAccount(firstName: "example", lastName: "example", email: "miguel.morales@srt.com", password: "example")
        switch result {
        case .success:
            XCTFail("Create account should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as! AccountError, AccountError.emailAlreadyInUse)
        }
    }

    func testSaveUserInfo_WithCorrectCredentials_ShouldReturnSuccess() async throws {
        await _ = accountProvider.login(email: "miguel.morales@srt.com", password: "123456")
        let railcard = UUID().uuidString
        let userInfoToSave = UserInfo(email: "miguel.morales@srt.com", firstName: "Miguel", lastName: "Morales", railcard: railcard)
        accountProvider.saveUserInfo(userInfo: userInfoToSave, completion: { error in
            XCTAssertNil(error)
        })
        let result = await self.accountProvider.getUserInfo()
        switch result {
        case .success(let userInfo):
            XCTAssertEqual(userInfo, userInfoToSave)
        case .failure(let error):
            XCTFail("Get user info failed with error: \(error)")
        }
    }
}
