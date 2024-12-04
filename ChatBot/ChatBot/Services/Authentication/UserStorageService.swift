import FirebaseFirestore

class UserStorageService {
    private let db = Firestore.firestore()

    func fetchUserDetails(userId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = document?.data() else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found."])))
                return
            }
            completion(.success(data))
        }
    }
}
