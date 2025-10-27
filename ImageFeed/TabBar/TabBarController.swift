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
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        imagesListViewController.tabBarItem.accessibilityIdentifier = "TabBarImagesListItem"
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        profileViewController.tabBarItem.accessibilityIdentifier = "TabBarProfileItem"
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}
