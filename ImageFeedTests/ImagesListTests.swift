import XCTest
@testable import ImageFeed

// MARK: - ImagesListPresenter Tests

final class ImagesListPresenterTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: ImagesListPresenter!
    private var service: ImagesListServiceSpy!
    private var viewController: ImagesListViewControllerSpy!
    
    // MARK: - Private Properties
    
    private let photos = [
        Photo(
            id: "0",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "test description 0",
            thumbImageURL: "https://example.com/thumb_test_0.png",
            smallImageURL: "https://example.com/small_test_0.png",
            regularImageURL: "https://example.com/regular_test_0.png",
            largeImageURL: "https://example.com/large_test_0.png",
            isLiked: false
        ),
        Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "test description 1",
            thumbImageURL: "https://example.com/thumb_test_1.png",
            smallImageURL: "https://example.com/small_test_1.png",
            regularImageURL: "https://example.com/regular_test_1.png",
            largeImageURL: "https://example.com/large_test_1.png",
            isLiked: false
        )
    ]
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        service = ImagesListServiceSpy()
        viewController = ImagesListViewControllerSpy()
        sut = ImagesListPresenter(service: service, photos: photos)
        viewController.presenter = sut
        sut.view = viewController
    }
    
    override func tearDown() {
        service = nil
        sut = nil
        viewController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testDownloadPhotosCallsFetchPhotosNextPage() {
        // Given
        let sut = sut!
        
        // When
        sut.downloadPhotos()
        
        // Then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testDidSelectPhotoCallsPresentSingleImageScreen() {
        // Given
        let sut = sut!
        
        // When
        sut.didSelectPhoto(indexPath: IndexPath(row: 1, section: 0))
        
        // Then
        XCTAssertTrue(viewController.presentSingleImageScreenCalled)
        XCTAssertEqual(viewController.correctURLString, "https://example.com/large_test_1.png")
    }
    
    func testGetNewIndexPaths() {
        // Given
        let startPhotos: [Photo] = []
        service.photos = photos
        let sut = ImagesListPresenter(service: service, photos: startPhotos)
        let newPhotosCount = photos.count
        
        // When
        let newPaths = sut.getNewIndexPaths()
        
        // Then
        XCTAssertEqual(newPaths.count, newPhotosCount)
    }
    
    func testGetNewIndexPathsWithoutChanges() {
        // Given
        let sut = sut!
        service.photos = self.photos
        
        // When
        let newPaths = sut.getNewIndexPaths()
        
        // Then
        XCTAssertTrue(newPaths.isEmpty)
    }
    
    func testChangeLikeCallsFetchLike() {
        // Given
        let sut = sut!
        let indexPath = IndexPath(row: photos.count - 1, section: 0)
        
        // When
        sut.changeLike(indexPath: indexPath)
        
        // Then
        XCTAssertTrue(service.fetchLikeCalled)
    }
    
    func testGetPhoto() throws {
        // Given
        let sut = sut!
        let indexPath = IndexPath(row: 1, section: 0)
        
        // When
        let photo = try XCTUnwrap(sut.getPhoto(indexPath: indexPath), "getPhoto(indexPath:) returns nil")
        
        // Then
        XCTAssertEqual(photo.id, self.photos[indexPath.row].id)
    }
    
    func testCalculateCellHeightWithWidhGreaterThanZero() throws {
        // Given
        let sut = sut!
        let indexPath = IndexPath(row: 1, section: 0)
        
        // When
        let height = try XCTUnwrap(
            sut.calculateCellHeight(
                indexPath: indexPath,
                viewWidth: 50,
                topInset: 5,
                bottomInset: 5
            ),
            "calculateHeight() returns nil"
        )
        
        // Then
        XCTAssertEqual(height, 60)
    }
    
    func testCalculateCellHeightWithZeroWidth() {
        // Given
        let photos = [
            Photo(
                id: "0",
                size: CGSize(width: 0, height: 100),
                createdAt: Date(),
                welcomeDescription: "test description 0",
                thumbImageURL: "https://example.com/thumb_test_0.png",
                smallImageURL: "https://example.com/small_test_0.png",
                regularImageURL: "https://example.com/regular_test_0.png",
                largeImageURL: "https://example.com/large_test_0.png",
                isLiked: false
            )
        ]
        
        let sut = ImagesListPresenter(service: service, photos: photos)
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        let height = sut.calculateCellHeight(
            indexPath: indexPath,
            viewWidth: 50,
            topInset: 5,
            bottomInset: 5
        )
        
        // Then
        XCTAssertNil(height)
    }
    
    func testIsValidIndexPath() {
        // Given
        let sut = sut!
        let validIndexPath = IndexPath(row: 1, section: 0)
        let invalidIndexPath = IndexPath(row: 2, section: 0)
        
        // When
        let validAnswer = sut.isValidIndexPath(validIndexPath)
        let invalidAnswer = sut.isValidIndexPath(invalidIndexPath)
        
        // Then
        XCTAssertTrue(validAnswer)
        XCTAssertFalse(invalidAnswer)
    }
    
    func testObservation() throws {
        // Given
        viewController.expectation = expectation(description: "updateTableViewAnimated() should be called")
        
        // When
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        // Then
        let expectation = try XCTUnwrap(viewController.expectation, "expectation returns nil")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
}

// MARK: - ImagesListViewController Tests

final class ImagesListViewControllerTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    private var sut: ImagesListViewController!
    private var presenter: ImagesListPresenterSpy!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        sut = ImagesListViewController()
        presenter = ImagesListPresenterSpy()
        sut.presenter = presenter
        presenter.view = sut
    }
    
    override func tearDown() {
        presenter = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testDownloadPhotosCallsWhenViewDidLoad() {
        // Given
        let sut = sut!
        
        // When
        _ = sut.view
        
        // Then
        XCTAssertTrue(presenter.downloadPhotosCalled)
    }
    
    func testUpdateTableViewAnimatedCallsGetNewIndexPaths() {
        // Given
        let sut = sut!
        
        // When
        sut.updateTableViewAnimated()
        
        // Then
        XCTAssertTrue(presenter.getNewIndexPathsCalled)
    }
    
}
