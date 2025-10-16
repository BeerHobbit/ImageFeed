import Foundation

final class ProfileImageService {
    
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    
    // MARK: - Notification
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Public Properties
    
    private(set) var avatarURL: String?
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var profileImageTask: URLSessionTask?
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfileImageURL(_ token: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        profileImageTask?.cancel()
        
        guard let request = makeProfileImageRequest(authToken: token, username: username) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        profileImageTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            defer { self.profileImageTask = nil }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.medium
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        profileImageTask?.resume()
    }
    
    func resetState() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    
    private func makeProfileImageRequest(authToken: String, username: String) -> URLRequest? {
        guard let publicProfileURL = URL(string: UnsplashURLs.unsplashUserPublicProfileURLString + username) else {
            assertionFailure("❌ [makeProfileImageRequest] Invalid URL for profile image request")
            return nil
        }
        
        var request = URLRequest(url: publicProfileURL)
        request.httpMethod = HttpMethods.get
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}
