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
    
    // MARK: - Loader Views
    
    private let avatarLoaderView: LoaderView = {
        let view = LoaderView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 35
        return view
    }()
    
    private let nameLoaderView: LoaderView = {
        let view = LoaderView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        return view
    }()
    
    private let loginLoaderView: LoaderView = {
        let view = LoaderView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        return view
    }()
    
    private let messageLoaderView: LoaderView = {
        let view = LoaderView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        return view
    }()
    
    private lazy var loaderVStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                avatarLoaderView,
                nameLoaderView,
                loginLoaderView,
                messageLoaderView
            ]
        )
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Private Properties
    
    private var profileService: ProfileService?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileLogoutService: ProfileLogoutService?
    
    private var isLoading = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        configActions()
        setupObserver()
        
        showLoadingState()
        
        updateProfileUI()
        updateAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loaderVStack.isHidden == false {
            animateLoaderViews()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLoaderViews()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        profileService = ProfileService.shared
        profileLogoutService = ProfileLogoutService.shared
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(vStack)
        
        view.addSubview(loaderVStack)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        userpickImageView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        vStack.translatesAutoresizingMaskIntoConstraints = false

        avatarLoaderView.translatesAutoresizingMaskIntoConstraints = false
        nameLoaderView.translatesAutoresizingMaskIntoConstraints = false
        loginLoaderView.translatesAutoresizingMaskIntoConstraints = false
        messageLoaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderVStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate(
            [
                userpickImageView.heightAnchor.constraint(equalToConstant: 70),
                userpickImageView.widthAnchor.constraint(equalToConstant: 70),
                
                logoutButton.heightAnchor.constraint(equalToConstant: 44),
                logoutButton.widthAnchor.constraint(equalToConstant: 44),
                
                vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                vStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                vStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                
                //DELETE
                avatarLoaderView.heightAnchor.constraint(equalToConstant: 70),
                avatarLoaderView.widthAnchor.constraint(equalToConstant: 70),
                
                nameLoaderView.heightAnchor.constraint(equalToConstant: 18),
                nameLoaderView.widthAnchor.constraint(equalToConstant: 225),
                
                loginLoaderView.heightAnchor.constraint(equalToConstant: 18),
                loginLoaderView.widthAnchor.constraint(equalToConstant: 90),
                
                messageLoaderView.heightAnchor.constraint(equalToConstant: 18),
                messageLoaderView.widthAnchor.constraint(equalToConstant: 65),
                
                loaderVStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                loaderVStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
                //DELETE
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
        userpickImageView.kf.setImage(with: url, placeholder: UIImage(resource: .userpickImageStub)) { [weak self] _ in
            guard let self else { return }
            self.hideLoadingState()
        }
    }
    
    private func logoutAndChangeRoot() {
        profileLogoutService?.logout()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("❌ [logoutAndChangeRoot] Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func showLogoutAlert() {
        
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.logoutAndChangeRoot()
        }
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
    private func animateLoaderViews() {
        loaderVStack.isHidden = false
        avatarLoaderView.animateGradient()
        nameLoaderView.animateGradient()
        loginLoaderView.animateGradient()
        messageLoaderView.animateGradient()
    }
    
    private func stopLoaderViews() {
        avatarLoaderView.stopAnimation()
        nameLoaderView.stopAnimation()
        loginLoaderView.stopAnimation()
        messageLoaderView.stopAnimation()
        loaderVStack.isHidden = true
    }
    
    private func hideUI(_ state: Bool) {
        state ? (vStack.isHidden = true) : (vStack.isHidden = false)
    }
    
    private func showLoadingState() {
        guard !isLoading else { return }
        isLoading = true
        hideUI(true)
        loaderVStack.isHidden = false
        animateLoaderViews()
    }
    
    private func hideLoadingState() {
        guard isLoading else { return }
        isLoading = false
        stopLoaderViews()
        loaderVStack.isHidden = true
        hideUI(false)
    }
    
}

