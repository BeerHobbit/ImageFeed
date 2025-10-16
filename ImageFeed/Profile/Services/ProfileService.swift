import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    
    static let shared = ProfileService()
    
    // MARK: - Public Properties
    
    private(set) var profile: Profile?
    
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
        
        profileTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            defer { self.profileTask = nil }
            
            switch result {
            case .success(let profileResult):
                let profile = makeProfile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        profileTask?.resume()
    }
    
    func resetState() {
        profile = nil
    }
    
    // MARK: - Private Methods
    
    private func makeProfile(from result: ProfileResult) -> Profile {
        Profile(
            username: result.username,
            name: "\(result.firstName) \(result.lastName ?? "")",
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
    
    private func makeProfileRequest(authToken: String) -> URLRequest? {
        guard let profileURL = URL(string: UnsplashURLs.unsplashUserProfileURLString) else {
            assertionFailure("❌ [makeProfileRequest] Invalid URL for profile request")
            return nil
        }
        
        var request = URLRequest(url: profileURL)
        request.httpMethod = HttpMethods.get
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}

