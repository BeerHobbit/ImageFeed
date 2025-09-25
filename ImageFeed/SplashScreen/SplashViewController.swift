import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var storage: OAuth2TokenStorage?
    private var profileService: ProfileService?
    private var profileImageService: ProfileImageService?
    private let authScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarStoryboardIdentifier = "TabBarViewController"
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTokenStorage()
    }
    
    // MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == authScreenSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard
            let destination = segue.destination as? UINavigationController,
            let viewController = destination.viewControllers.first as? AuthViewController
        else {
            assertionFailure("❌ [prepare] Failed to prepare for \(authScreenSegueIdentifier)")
            return
        }
        
        viewController.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func configDependencies() {
        storage = OAuth2TokenStorage.shared
        profileService = ProfileService.shared
        profileImageService = ProfileImageService.shared
    }
    
    private func checkTokenStorage() {
        let token = storage?.token
        if token != nil {
            guard let token = token else {
                print("❌ [checkTokenStorage] Token does not exist")
                return
            }
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: authScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [switchToTabBarController] Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: tabBarStoryboardIdentifier)
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService?.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                let username = profile.username
                profileImageService?.fetchProfileImageURL(token, username: username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print(error)
                self.showErrorAlert()
                break
            }
        }
    }
    
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.navigationController?.dismiss(animated: true)
    }
    
}
