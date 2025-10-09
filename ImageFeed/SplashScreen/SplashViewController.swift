import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Views
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .launchScreenLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Private Properties
    
    private var storage: OAuth2TokenStorage?
    private var profileService: ProfileService?
    private var profileImageService: ProfileImageService?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTokenStorage()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        storage = OAuth2TokenStorage.shared
        profileService = ProfileService.shared
        profileImageService = ProfileImageService.shared
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    // MARK: - Private Methods
    
    private func checkTokenStorage() {
        let token = storage?.token
        if token != nil {
            guard let token = token else { return }
            fetchProfile(token: token)
        } else {
            presentAuthNavigationController()
        }
    }
    
    private func presentAuthNavigationController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = AuthNavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [switchToTabBarController] Invalid window configuration")
            return
        }
        let tabBarController = MainTabBarController()
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show(isBlockingUI: true)
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
