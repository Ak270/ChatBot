import FirebaseAuth

protocol AuthenticationService {
    func signUpWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func loginWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func socialLogin(provider: SocialProvider, completion: @escaping (Result<User, Error>) -> Void)
    func saveAdditionalUserInfo(userId: String, username: String, apiToken: String, completion: @escaping (Error?) -> Void)
}
