import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("<your email>")
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("<your password>")
        app.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let table = app.tables["ImagesListTable"]
        let cell = table.cells.element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let table = app.tables["ImagesListTable"]
        table.swipeUp()
        table.swipeDown()
        
        let cellToLike = table.cells.firstMatch
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        
        cellToLike.tap()
        
        let image = app.images["SingleImage"]
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["BackwardButton"]
        backButton.tap()
        
        XCTAssertTrue(table.waitForExistence(timeout: 5))
    }
    
    func testProfile() throws {
        let profileButton = app.tabBars.buttons["TabBarProfileItem"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5))
        profileButton.tap()
        
        XCTAssertTrue(app.staticTexts["<your name>"].exists)
        XCTAssertTrue(app.staticTexts["<your login>"].exists)
        
        app.buttons["LogoutButton"].tap()
        
        let alert = app.alerts["LogoutAlert"]
        alert.buttons["LogoutYesButton"].tap()
        
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
    }
    
}
