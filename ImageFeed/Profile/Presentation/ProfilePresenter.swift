import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - View
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private var profileService: ProfileServiceProtocol?
    private var profileImageService: ProfileImageServiceProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileLogoutService: ProfileLogoutServiceProtocol?
    
    // MARK: - Initializer
    
    init(
        service: ProfileServiceProtocol = ProfileService.shared,
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        profileService = service
        profileImageService = imageService
        profileLogoutService = logoutService
        setupObserver()
    }
    
    // MARK: - ProfilePresenterProtocol
    
    func getProfile() -> Profile? {
        return profileService?.profile
    }
    
    func getAvatarURL() -> URL? {
        guard let profileImageURL = profileImageService?.avatarURL else { return nil }
        return URL(string: profileImageURL)
    }
    
    func logoutAndChangeRoot() {
        profileLogoutService?.logout()
        view?.changeToSplashScreen()
    }
    
    // MARK: - Private Methods
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            guard let self = self else { return }
            self.view?.updateAvatar()
        }
    }
    
}
