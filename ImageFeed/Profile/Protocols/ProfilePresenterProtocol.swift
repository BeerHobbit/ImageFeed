import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func getProfile() -> Profile?
    func getAvatarURL() -> URL?
    func logoutAndChangeRoot()
}
