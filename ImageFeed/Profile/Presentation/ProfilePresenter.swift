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
    
    init() {
        configDependencies()
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
    
    private func configDependencies() {
        profileService = ProfileService.shared
        profileImageService = ProfileImageService.shared
        profileLogoutService = ProfileLogoutService.shared
    }
    
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
