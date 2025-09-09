import Foundation

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            let token = storage.string(forKey: Keys.accessToken.rawValue)
            return token
        }
        set {
            storage.set(newValue,forKey: Keys.accessToken.rawValue)
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case accessToken
    }
    
}

