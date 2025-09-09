import UIKit

final class AuthViewController: UIViewController {
    
    //MARK: - IB Outlets
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var loginButton: UIButton!
    
    //MARK: - Delegate
    
    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - Private Propeties
    
    private let authWebViewSegueIdentifier = "ShowWebView"
    private var oauth2Service: OAuth2Service?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
    }
    
    //MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == authWebViewSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let destination = segue.destination as? WebViewViewController else {
            assertionFailure("❌ Failed to prepare for \(authWebViewSegueIdentifier)")
            return
        }
        
        destination.delegate = self
    }
    
    //MARK: - Private Methods
    
    private func configUI() {
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    private func configDependencies() {
        oauth2Service = OAuth2Service.shared
    }
    
    private func presentErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        print("Code: \(code)")
        
        oauth2Service?.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let accessToken):
                let oauth2TokenStorage = OAuth2TokenStorage()
                oauth2TokenStorage.token = accessToken
                print("Bearer Token: \(oauth2TokenStorage.token ?? "nil")")
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                self.presentErrorAlert()
                print(error)
            }
        }
    }
    
}
