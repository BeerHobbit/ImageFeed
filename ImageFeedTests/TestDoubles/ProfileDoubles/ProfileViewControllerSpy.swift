import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    private(set) var changeToSplashScreenCalled: Bool = false
    private(set) var updateAvatarCalled: Bool = false
    var expectation: XCTestExpectation?
    
    var presenter: ProfilePresenterProtocol?
    
    func updateAvatar() {
        updateAvatarCalled = true
        expectation?.fulfill()
    }
    
    func changeToSplashScreen() {
        changeToSplashScreenCalled = true
    }
    
}

