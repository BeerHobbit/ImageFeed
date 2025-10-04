import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Singleton
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Token
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: Keys.token)
        }
        set {
            if let token = newValue {
                let isSuccess = keychainWrapper.set(token, forKey: Keys.token)
                guard isSuccess else {
                    print("❌ [OAuth2TokenStorage] KeychainWrapper error: newValue was not set for key \(Keys.token)")
                    return
                }
            } else {
                let isRemoved = keychainWrapper.removeObject(forKey: Keys.token)
                guard isRemoved else {
                    print("❌ [OAuth2TokenStorage] KeychainWrapper error: value for key \(Keys.token) was not removed")
                    return
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let keychainWrapper = KeychainWrapper.standard
    private enum Keys {
        static let token = "token"
    }
    
    // MARK: - Initializer
    
    private init() {}
    
}
