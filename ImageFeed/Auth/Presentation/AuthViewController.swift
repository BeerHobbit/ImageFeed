import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    // MARK: - Views
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unsplashLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        return button
    }()
    
    // MARK: - Delegate
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Propeties
    
    private var webViewViewController: WebViewViewController?
    private var oauth2Service: OAuth2Service?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        configActions()
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
        view.addSubview(loginButton)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                logoImageView.widthAnchor.constraint(equalToConstant: 60),
                logoImageView.heightAnchor.constraint(equalToConstant: 60),
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                loginButton.heightAnchor.constraint(equalToConstant: 48),
                loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
            ]
        )
    }
    
    // MARK: - Configure Actions
    
    private func configActions() {
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLoginButton() {
        pushToWebViewViewController()
    }
    
    // MARK: - Private Methods
    
    private func configDependencies() {
        oauth2Service = OAuth2Service.shared
        webViewViewController = WebViewViewController()
        guard let webViewViewController = webViewViewController else { return }
        webViewViewController.delegate = self
    }
    
    private func pushToWebViewViewController() {
        guard let webViewViewController = webViewViewController else { return }
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        print("Code: \(code)")
        UIBlockingProgressHUD.show(isBlockingUI: true)
        
        oauth2Service?.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let accessToken):
                let oauth2TokenStorage = OAuth2TokenStorage.shared
                oauth2TokenStorage.token = accessToken
                print("Bearer Token: \(oauth2TokenStorage.token ?? "nil")")
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print(error)
                self.showErrorAlert()
            }
        }
    }
    
}
