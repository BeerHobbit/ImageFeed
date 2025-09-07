import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    
    private let storage = OAuth2TokenStorage()
    private let authScreenSegueID = "showAuthenticationScreenSegueIdentifier"
    private let tabBarStoryboardID = "TabBarViewController"
    
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTokenStorage()
    }
    
    
    //MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == authScreenSegueID else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard
            let destination = segue.destination as? UINavigationController,
            let viewController = destination.viewControllers.first as? AuthViewController
        else {
            assertionFailure("❌ Failed to prepare for \(authScreenSegueID)")
            return
        }
        
        viewController.delegate = self
    }
    
    
    //MARK: - Private Methods
    
    private func checkTokenStorage() {
        if storage.token != nil {
           switchToTabBarController()
        } else {
            performSegue(withIdentifier: authScreenSegueID, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: tabBarStoryboardID)
        
        window.rootViewController = tabBarController
    }
    
}


//MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.navigationController?.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.switchToTabBarController()
        }
    }

}
