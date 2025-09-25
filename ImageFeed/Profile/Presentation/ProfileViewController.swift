import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
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
        let buttonImage = UIImage(named: "logout_button")
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
    
    // MARK: - Private Properties
    
    private var profileService: ProfileService?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        configActions()
        setupObserver()
        updateProfileUI()
        updateAvatar()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        profileService = ProfileService.shared
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
    private func didTapLogoutButton(_ sender: UIButton) {} // TODO: add an action to the button
    
    // MARK: - Private Methods
    
    private func updateProfileUI() {
        guard let profile = profileService?.profile else { return }
        usernameLabel.text = profile.name
        loginLabel.text = profile.loginName
        profileDescriptionLabel.text = profile.bio
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        userpickImageView.kf.indicatorType = .activity
        userpickImageView.kf.setImage(with: url, placeholder: UIImage(named: "userpick_image_stub"))
    }

}

