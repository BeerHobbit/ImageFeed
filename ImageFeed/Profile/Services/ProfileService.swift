import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    
    static let shared = ProfileService()
    
    // MARK: - Public Properties
    
    var profile: Profile?
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var profileTask: URLSessionTask?
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        profileTask?.cancel()
        
        guard let request = makeProfileRequest(authToken: token) else {
            print("❌ [makeProfileRequest] Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            self.profileTask = nil
        }
        
        self.profileTask = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeProfileRequest(authToken: String) -> URLRequest? {
        guard let profileURL = URL(string: UnsplashURLs.unsplashUserProfileURLString) else {
            print("❌ [makeProfileRequest] Incorrect user profile URL")
            return nil
        }
        
        var request = URLRequest(url: profileURL)
        request.httpMethod = HttpMethods.get
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}

