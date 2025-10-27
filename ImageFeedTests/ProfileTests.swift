import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    // MARK: - ProfilePresenter Tests
    
    func testGetProfile() throws {
        //given
        let service = ProfileServiceStub()
        service.profile = Profile(
            username: "test username",
            name: "test name",
            loginName: "test login",
            bio: "test bio"
        )
        let sut = ProfilePresenter(service: service)
        
        //when
        let profile = try XCTUnwrap(sut.getProfile(), "getProfile() returns nil")
        
        //then
        XCTAssertEqual(profile.username, "test username")
        XCTAssertEqual(profile.name, "test name")
        XCTAssertEqual(profile.loginName, "test login")
        XCTAssertEqual(profile.bio, "test bio")
    }
    
    func testGetProfileReturnsNil() {
        //given
        let service = ProfileServiceStub()
        service.profile = nil
        let sut = ProfilePresenter(service: service)
        
        //when
        let profile = sut.getProfile()
        
        //then
        XCTAssertNil(profile)
    }
    
    func testGetAvatarURL() throws {
        //given
        let imageService = ProfileImageServiceStub()
        imageService.avatarURL = "https://example.com/test.png"
        let sut = ProfilePresenter(imageService: imageService)
        
        //when
        let url = try XCTUnwrap(sut.getAvatarURL(), "getAvatarURL() returns nil")
        
        //then
        XCTAssertEqual(url.absoluteString, "https://example.com/test.png")
    }
    
    func testGetAvatarURLReturnsNil() {
        //given
        let imageService = ProfileImageServiceStub()
        imageService.avatarURL = nil
        let sut = ProfilePresenter(imageService: imageService)
        
        //when
        let url = sut.getAvatarURL()
        
        //then
        XCTAssertNil(url)
    }
    
    func testLogoutAndChangeRootCallsLogoutAndChangeToSplashScreen() {
        //given
        let logoutService = ProfileLogoutServiceSpy()
        let viewController = ProfileViewControllerSpy()
        let sut = ProfilePresenter(logoutService: logoutService)
        viewController.presenter = sut
        sut.view = viewController
        
        //when
        sut.logoutAndChangeRoot()
        
        //then
        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(viewController.changeToSplashScreenCalled)
    }
    
    func testObservation() throws {
        //given
        let sut = ProfilePresenter()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = sut
        sut.view = viewController
        viewController.expectation = expectation(description: "updateAvatar() should be called")
        
        //when
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
        
        //then
        let expectation = try XCTUnwrap(viewController.expectation, "expectation returns nil")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    // MARK: - ProfileViewController Tests
    
    func testUpdateAvatarCallsGetAvatarURL() {
        //given
        let presenter = ProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.presenter = presenter
        presenter.view = sut
        
        //when
        sut.updateAvatar()
        
        //then
        XCTAssertTrue(presenter.getAvatarURLCalled)
    }
    
    func testUpdateAvatarCallsGetAvatarURLWhenViewDidLoad() {
        //given
        let presenter = ProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.presenter = presenter
        presenter.view = sut
        
        //when
        _ = sut.view
        
        //then
        XCTAssertTrue(presenter.getAvatarURLCalled)
    }
    
    func testUpdateProfileUICallsGetProfileWhenViewDidLoad() {
        //given
        let presenter = ProfilePresenterSpy()
        let sut = ProfileViewController()
        sut.presenter = presenter
        presenter.view = sut
        
        //when
        _ = sut.view
        
        //then
        XCTAssertTrue(presenter.getProfileCalled)
    }
    
}
