import UIKit

final class ProfileViewController: UIViewController {
    
    //MARK: - Views
    
    private let userpickImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "userpick")
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
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
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
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
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configConstraints()
        configActions()
    }
    
    
    //MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(vStack)
    }
    
    
    //MARK: - Configure Constraints
    
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
    
    
    //MARK: - Configure Actions
    
    private func configActions() {
        logoutButton.addTarget(self, action: #selector (didTapLogoutButton(_:)), for: .touchUpInside)
    }
    
    
    //MARK: - Actions
    
    @objc
    private func didTapLogoutButton(_ sender: UIButton) {} // Do to some next sprint
    
}

