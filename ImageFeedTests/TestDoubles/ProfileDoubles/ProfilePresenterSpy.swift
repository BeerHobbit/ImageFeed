import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    private(set) var getProfileCalled: Bool = false
    private(set) var getAvatarURLCalled: Bool = false
    private(set) var logoutAndChangeRootCalled: Bool = false
    
    weak var view: ProfileViewControllerProtocol?
    
    func getProfile() -> Profile? {
        getProfileCalled = true
        return nil
    }
    
    func getAvatarURL() -> URL? {
        getAvatarURLCalled = true
        return nil
    }
    
    func logoutAndChangeRoot() {}
    
}

