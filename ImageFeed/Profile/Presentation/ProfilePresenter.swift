import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    //MARK: - View
    
    var view: ProfileViewControllerProtocol?
    
    private var profileService: ProfileService?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileLogoutService: ProfileLogoutService?
    
    init() {
        profileService = ProfileService.shared
        profileLogoutService = ProfileLogoutService.shared
    }
    
    
    
    
}
