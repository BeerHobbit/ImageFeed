import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configTabs()
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        tabBar.tintColor = .ypWhite
        tabBar.barTintColor = .ypBlack
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .ypBlack
    }
    
    // MARK: - Private Methods
    
    private func configTabs() {
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}
