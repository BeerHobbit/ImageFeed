import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Singleton
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func logout() {
        tokenStorage.token = nil
        cleanCookies()
        profileService.profile = nil
        profileImageService.avatarURL = nil
        imagesListService.photos = []
        imagesListService.lastLoadedPage = nil
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
}
