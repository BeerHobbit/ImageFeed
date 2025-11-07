import XCTest
@testable import ImageFeed

// MARK: - WebViewViewControllerTests

final class WebViewViewControllerTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: WebViewViewController!
    private var presenter: WebViewPresenterSpy!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        sut = WebViewViewController()
        presenter = WebViewPresenterSpy()
        sut.presenter = presenter
        presenter.view = sut
    }
    
    override func tearDown() {
        sut = nil
        presenter = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testViewControllerCallsDidLoad() {
        // Given
        let sut = sut!
        
        // When
        _ = sut.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
}

// MARK: - WebViewPresenter Tests

final class WebViewPresenterTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: WebViewPresenter!
    private var viewController: WebViewViewControllerSpy!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        sut = WebViewPresenter(authHelper: AuthHelper())
        viewController = WebViewViewControllerSpy()
        viewController.presenter = sut
        sut.view = viewController
    }
    
    override func tearDown() {
        sut = nil
        viewController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testPresenterCallsLoadRequest() {
        // Given
        let sut = sut!
        
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let sut = sut!
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = sut.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // Given
        let sut = sut!
        let progress: Float = 1
        
        // When
        let shouldHideProgress = sut.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertTrue(shouldHideProgress)
    }
    
}

// MARK: - AuthHelper Tests

final class AuthHelperTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: AuthHelper!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        sut = AuthHelper(configuration: .standard)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testAuthHelperAuthURL() throws {
        // Given
        let sut = sut!
        let configuration = AuthConfiguration.standard
        
        // When
        let url = sut.authURL()
        let urlString = try XCTUnwrap(url?.absoluteString, "authURL() returns nil")
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() throws {
        // Given
        let sut = sut!
        var urlComponents = try XCTUnwrap(URLComponents(string: "https://unsplash.com/oauth/authorize/native"), "URLComponents(string:) returns nil")
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = try XCTUnwrap(urlComponents.url, "urlComponents.url returns nil")
        
        // When
        let code = sut.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code")
    }
    
}
