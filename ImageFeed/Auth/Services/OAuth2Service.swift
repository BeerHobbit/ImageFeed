import Foundation

final class OAuth2Service {
    
    //MARK: - Singleton
    
    static let shared = OAuth2Service()
    
    //MARK: - Initializer
    
    private init() {}
    
    //MARK: - Public Methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ Failed to create request")
            return
        }
        
        let session = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = response.accessToken
                    completion(.success(accessToken))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                    print("❌ Unable to decode data: \(error)")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        session.resume()
    }
    
    //MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashTokenRequestURLString) else {
            print("❌ Incorrect token request URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenURL = urlComponents.url else {
            print("❌ Incorrect token request URL with parameters")
            return nil
        }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        return request
    }
    
}

