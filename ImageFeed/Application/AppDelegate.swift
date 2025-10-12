import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .ypWhite
        ProgressHUD.colorAnimation = .ypBlack
        ProgressHUD.mediaSize = 30
        ProgressHUD.marginSize = 20
        return true
    }

}

