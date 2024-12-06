
import XCTest
@testable import ChatBot
import FirebaseAuth
import Firebase

final class AuthServiceTests: XCTestCase {
    
    var authService: FirebaseAuthService!
    
    override func setUp() {
        super.setUp()
        // Initialize Firebase for testing
        let options = FirebaseOptions(googleAppID: "1:947960277660:ios:5e840b013674e7bccedb59",
                                      gcmSenderID: "947960277660")
        options.apiKey = "AIzaSyBWf7Cq79EiWrxJJhQ9BdTwB-L6t32RpEQ"
        options.projectID = "chatbot-bf688"
        options.clientID = "947960277660-rhjpa592a8769su1k3epq55tnnnqhafp.apps.googleusercontent.com"
        
        FirebaseApp.configure(options: options)
        authService = FirebaseAuthService()
    }
    
    override func tearDown() {
        authService = nil
        super.tearDown()
    }
    
    func testSignUpWithEmail() {
        let expectation = self.expectation(description: "User should sign up successfully.")
        
        let email = "testuser@example.com"
        let password = "TestPassword123!"
        
        authService.signUpWithEmail(email: email, password: password) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user.uid, "User ID should not be nil.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Sign up failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testLoginWithEmail() {
        let expectation = self.expectation(description: "User should log in successfully.")
        
        let email = "testuser@example.com"
        let password = "TestPassword123!"
        
        authService.loginWithEmail(email: email, password: password) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user.uid, "User ID should not be nil.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Login failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testSocialLoginWithGoogle() {
        let expectation = self.expectation(description: "Google login should be tested.")
        
        authService.socialLogin(provider: .google) { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user.uid, "Google user ID should not be nil.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Google login failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    
    
    func testLogout() {
        let expectation = self.expectation(description: "User should log out successfully.")
        
        // Simulate user sign-in for testing
        Auth.auth().signIn(withEmail: "testuser@example.com", password: "TestPassword123!") { result, error in
            guard let _ = result, error == nil else {
                XCTFail("Sign-in failed. Can't test logout.")
                return
            }
            
            // Now test logout
            self.authService.logout { result in
                switch result {
                case .success(let success):
                    XCTAssertTrue(success, "Logout should succeed.")
                    XCTAssertNil(Auth.auth().currentUser, "User should be logged out.")
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Logout failed with error: \(error.localizedDescription)")
                }
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testSaveAdditionalUserInfoAfterLogin() {
        let expectation = self.expectation(description: "Additional user info should be saved successfully after login.")
        
        // Test credentials
        let email = "testuser@example.com"
        let password = "TestPassword123!"
        let mockUsername = "TestUser"
        let mockApiToken = "TestAPIToken123"
        
        // First, log in the user to get the userId
        authService.loginWithEmail(email: email, password: password) { result in
            switch result {
            case .success(let user):
                let userId = user.uid // Retrieve the userId after successful login
                
                // Save additional user info
                self.authService.saveAdditionalUserInfo(userId: email, username: mockUsername, apiToken: mockApiToken) { error in
                    if let error = error {
                        XCTFail("Saving additional user info failed: \(error.localizedDescription)")
                    } else {
                        // Verify if the information was saved correctly in Firestore
                        let db = Firestore.firestore()
                        db.collection("users").document(userId).getDocument { document, error in
                            if let error = error {
                                XCTFail("Error fetching document: \(error.localizedDescription)")
                            } else if let document = document, document.exists {
                                let data = document.data()
                                XCTAssertEqual(data?["username"] as? String, mockUsername, "Username should match.")
                                XCTAssertEqual(data?["apiToken"] as? String, mockApiToken, "API token should match.")
                                expectation.fulfill()
                            } else {
                                XCTFail("Document does not exist.")
                            }
                        }
                    }
                }
            case .failure(let error):
                XCTFail("Login failed with error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testResetPassword() {
        let expectation = self.expectation(description: "Password reset email should be sent.")
        
        let email = "testuser@example.com"
        
        authService.resetPassword(email: email) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Password reset email sent successfully.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Password reset failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5)
    }
    
}
