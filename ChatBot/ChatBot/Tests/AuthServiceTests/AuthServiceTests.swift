
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
    
//    func testLogout() {
//        let expectation = self.expectation(description: "User should log out successfully.")
//        
//        authService.logout { success in
//            XCTAssertTrue(success, "Logout should succeed.")
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 5)
//    }
}