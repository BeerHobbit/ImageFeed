import XCTest
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    private(set) var presentSingleImageScreenCalled: Bool = false
    private(set) var correctURLString: String = ""
    private(set) var updateTableViewAnimatedCalled: Bool = false
    var expectation: XCTestExpectation?
    
    var presenter: ImagesListPresenterProtocol?
    
    func showLoadingIndicator(isBlockingUI: Bool) {}
    
    func hideLoadingIndicator() {}
    
    func presentSingleImageScreen(url: URL) {
        presentSingleImageScreenCalled = true
        correctURLString = url.absoluteString
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
        expectation?.fulfill()
    }
    
    func updateLikeState(indexPath: IndexPath, isLiked: Bool) {}
    
    func presentErrorAlert() {}
    
}
