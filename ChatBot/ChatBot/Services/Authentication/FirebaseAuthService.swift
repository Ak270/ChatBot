import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

enum SocialProvider {
    case google
    case facebook
}

class FirebaseAuthService: AuthenticationService {
    
    private let db = Firestore.firestore()
    private var userMap: [String: String] = [:] // Maps email to userId
    
    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                return
            }
            self.updateUserMap(email: email, userId: user.uid)
            completion(.success(user))
        }
    }
    
    func loginWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
                return
            }
            self.updateUserMap(email: email, userId: user.uid)
            completion(.success(user))
        }
    }
    
    func socialLogin(provider: SocialProvider, completion: @escaping (Result<User, Error>) -> Void) {
        switch provider {
        case .google:
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                completion(.failure(NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Google client ID not found."])))
                return
            }
            
            let presentingVC = UIApplication.shared.windows.first?.rootViewController
            guard let rootViewController = presentingVC else {
                completion(.failure(NSError(domain: "AuthError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No presenting view controller available."])))
                return
            }
            
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let user = signInResult?.user,
                      let idToken = user.idToken?.tokenString else {
                    completion(.failure(NSError(domain: "AuthError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Google authentication failed."])))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let firebaseUser = authResult?.user else {
                        completion(.failure(NSError(domain: "AuthError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Google login failed."])))
                        return
                    }
                    
                    // Check if the user exists in Firestore
                    let userId = firebaseUser.uid
                    self.db.collection("users").document(userId).getDocument { document, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        if document?.exists == true {
                            // Existing user
                            completion(.success(firebaseUser))
                        } else {
                            // New user
                            completion(.failure(NSError(domain: "NewUser", code: 6, userInfo: [NSLocalizedDescriptionKey: "New user. Onboarding required."])))
                        }
                    }
                }
            }
        default:
            print("lol")
            
        }
    }
    
    func logout(completion: @escaping (Result<Bool, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            // If Google sign-in was used
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.signOut()
            }
            
            // Sign out from Firebase
            try firebaseAuth.signOut()
            completion(.success(true))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
    func updateUserMap(email: String, userId: String) {
        userMap[email] = userId
    }
    
    func saveAdditionalUserInfo(userId email: String, username: String, apiToken: String, completion: @escaping (Error?) -> Void) {
        guard let userId = userMap[email] else {
            completion(NSError(domain: "UserMapError", code: 1, userInfo: [NSLocalizedDescriptionKey: "UserId not found for email."]))
            return
        }
        
        let userInfo: [String: Any] = ["username": username, "apiToken": apiToken]
        
        db.collection("users").document(userId).setData(userInfo, merge: true) { error in
            if let error = error {
                print("Error saving additional user info: \(error.localizedDescription)")
            } else {
                print("Successfully saved additional user info for userId: \(userId)")
            }
            completion(error)
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
