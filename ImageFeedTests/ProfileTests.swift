import XCTest
@testable import ImageFeed

// MARK: - ProfilePresenter Tests

final class ProfilePresenterTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: ProfilePresenter!
    private var service: ProfileServiceStub!
    private var imageService: ProfileImageServiceStub!
    private var logoutService: ProfileLogoutServiceSpy!
    private var viewController: ProfileViewControllerSpy!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        service = ProfileServiceStub()
        imageService = ProfileImageServiceStub()
        logoutService = ProfileLogoutServiceSpy()
        viewController = ProfileViewControllerSpy()
        
        sut = ProfilePresenter(
            service: service,
            imageService: imageService,
            logoutService: logoutService
        )
        
        viewController.presenter = sut
        sut.view = viewController
    }
    
    override func tearDown() {
        service = nil
        imageService = nil
        logoutService = nil
        sut = nil
        viewController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetProfile() throws {
        // Given
        let sut = sut!
        service.profile = Profile(
            username: "test username",
            name: "test name",
            loginName: "test login",
            bio: "test bio"
        )
        
        // When
        let profile = try XCTUnwrap(sut.getProfile(), "getProfile() returns nil")
        
        // Then
        XCTAssertEqual(profile.username, "test username")
        XCTAssertEqual(profile.name, "test name")
        XCTAssertEqual(profile.loginName, "test login")
        XCTAssertEqual(profile.bio, "test bio")
    }
    
    func testGetProfileReturnsNil() {
        // Given
        let sut = sut!
        service.profile = nil
        
        // When
        let profile = sut.getProfile()
        
        // Then
        XCTAssertNil(profile)
    }
    
    func testGetAvatarURL() throws {
        // Given
        let sut = sut!
        imageService.avatarURL = "https://example.com/test.png"
        
        // When
        let url = try XCTUnwrap(sut.getAvatarURL(), "getAvatarURL() returns nil")
        
        // Then
        XCTAssertEqual(url.absoluteString, "https://example.com/test.png")
    }
    
    func testGetAvatarURLReturnsNil() {
        // Given
        let sut = sut!
        imageService.avatarURL = nil
        
        // When
        let url = sut.getAvatarURL()
        
        // Then
        XCTAssertNil(url)
    }
    
    func testLogoutAndChangeRootCallsLogoutAndChangeToSplashScreen() {
        // Given
        let sut = sut!
        
        // When
        sut.logoutAndChangeRoot()
        
        // Then
        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(viewController.changeToSplashScreenCalled)
    }
    
    func testObservation() throws {
        // Given
        viewController.expectation = expectation(description: "updateAvatar() should be called")
        
        // When
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
        
        // Then
        let expectation = try XCTUnwrap(viewController.expectation, "expectation returns nil")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
}
    
// MARK: - ProfileViewController Tests

final class ProfileViewControllerTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: ProfileViewController!
    private var presenter: ProfilePresenterSpy!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        presenter = ProfilePresenterSpy()
        sut.presenter = presenter
        presenter.view = sut
    }
    
    override func tearDown() {
        presenter = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testUpdateAvatarCallsGetAvatarURL() {
        // Given
        let sut = sut!
        
        // When
        sut.updateAvatar()
        
        // Then
        XCTAssertTrue(presenter.getAvatarURLCalled)
    }
    
    func testUpdateAvatarCallsGetAvatarURLWhenViewDidLoad() {
        // Given
        let sut = sut!
        
        // When
        _ = sut.view
        
        // Then
        XCTAssertTrue(presenter.getAvatarURLCalled)
    }
    
    func testUpdateProfileUICallsGetProfileWhenViewDidLoad() {
        // Given
        let sut = sut!
        
        // When
        _ = sut.view
        
        // Then
        XCTAssertTrue(presenter.getProfileCalled)
    }
    
}
