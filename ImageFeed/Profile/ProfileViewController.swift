import UIKit

final class ProfileViewController: UIViewController {
    
    //MARK: IB Outlets
    
    @IBOutlet private weak var userpickImageView: UIImageView!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var profileDescriptionLabel: UILabel!
    
    
    //MARK: IB Actions
    
    @IBAction private func logoutButtonClicked(_ sender: UIButton) { }
    
}

