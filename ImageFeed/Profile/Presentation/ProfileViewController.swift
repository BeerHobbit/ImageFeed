import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Presenter
    
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Views
    
    private let userpickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(resource: .logoutButton)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .ypRed
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                userpickImageView,
                UIView(),
                logoutButton
            ]
        )
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                hStack,
                usernameLabel,
                loginLabel,
                profileDescriptionLabel
            ]
        )
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configConstraints()
        configActions()
        updateProfileUI()
        updateAvatar()
    }
    
    // MARK: - ProfileViewControllerProtocol
    
    func updateAvatar() {
        guard let url = presenter?.getAvatarURL() else { return }
        userpickImageView.kf.indicatorType = .activity
        userpickImageView.kf.setImage(with: url, placeholder: UIImage(resource: .userpickImageStub))
    }
    
    func changeToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [logoutAndChangeRoot] Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(vStack)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        userpickImageView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                userpickImageView.heightAnchor.constraint(equalToConstant: 70),
                userpickImageView.widthAnchor.constraint(equalToConstant: 70),
                
                logoutButton.heightAnchor.constraint(equalToConstant: 44),
                logoutButton.widthAnchor.constraint(equalToConstant: 44),
                
                vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                vStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                vStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ]
        )
    }
    
    // MARK: - Configure Actions
    
    private func configActions() {
        logoutButton.addTarget(self, action: #selector (didTapLogoutButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton(_ sender: UIButton) {
        showLogoutAlert()
    }
    
    // MARK: - Private Methods
    
    private func updateProfileUI() {
        guard let profile = presenter?.getProfile() else { return }
        usernameLabel.text = profile.name
        loginLabel.text = profile.loginName
        profileDescriptionLabel.text = profile.bio
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.logoutAndChangeRoot()
        }
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
}

