import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
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
    
    // MARK: - ImagesListPresenter Tests
    
    func testDownloadPhotosCallsFetchPhotosNextPage() {
        //given
        let service = ImagesListServiceSpy()
        let sut = ImagesListPresenter(service: service)
        
        //when
        sut.downloadPhotos()
        
        //then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testDidSelectPhotoCallsPresentSingleImageScreen() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let photos = self.photos
        let sut = ImagesListPresenter(photos: photos)
        viewController.presenter = sut
        sut.view = viewController
        
        //when
        sut.didSelectPhoto(indexPath: IndexPath(row: 1, section: 0))
        
        //then
        XCTAssertTrue(viewController.presentSingleImageScreenCalled)
        XCTAssertEqual(viewController.correctURLString, "https://example.com/large_test_1.png")
    }
    
    func testGetNewIndexPaths() {
        //given
        let startPhotos: [Photo] = []
        let service = ImagesListServiceSpy()
        service.photos = self.photos
        let sut = ImagesListPresenter(service: service, photos: startPhotos)
        let newPhotosCount = photos.count
        
        //when
        let newPaths = sut.getNewIndexPaths()
        
        //then
        XCTAssertEqual(newPaths.count, newPhotosCount)
    }
    
    func testGetNewIndexPathsWithoutChanges() {
        //given
        let service = ImagesListServiceSpy()
        service.photos = self.photos
        let sut = ImagesListPresenter(service: service, photos: self.photos)
        
        //when
        let newPaths = sut.getNewIndexPaths()
        
        //then
        XCTAssertTrue(newPaths.isEmpty)
    }
    
    func testChangeLikeCallsFetchLike() {
        //given
        let service = ImagesListServiceSpy()
        let photos = self.photos
        let sut = ImagesListPresenter(service: service, photos: photos)
        let indexPath = IndexPath(row: photos.count - 1, section: 0)
        
        //when
        sut.changeLike(indexPath: indexPath)
        
        //then
        XCTAssertTrue(service.fetchLikeCalled)
    }
    
    func testGetPhoto() throws {
        //given
        let photos = self.photos
        let sut = ImagesListPresenter(photos: photos)
        let indexPath = IndexPath(row: 1, section: 0)
        
        //when
        let photo = try XCTUnwrap(sut.getPhoto(indexPath: indexPath), "getPhoto(indexPath:) returns nil")
        
        //then
        XCTAssertEqual(photo.id, self.photos[indexPath.row].id)
    }
    
    func testCalculateCellHeightWithWidhGreaterThanZero() throws {
        //given
        let photos = self.photos
        let sut = ImagesListPresenter(photos: photos)
        let indexPath = IndexPath(row: 1, section: 0)
        
        //when
        let height = try XCTUnwrap(
            sut.calculateCellHeight(
                indexPath: indexPath,
                viewWidth: 50,
                topInset: 5,
                bottomInset: 5
            ),
            "calculateHeight() returns nil"
        )
        
        //then
        XCTAssertEqual(height, 60)
    }
    
    func testCalculateCellHeightWithZeroWidth() {
        //given
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
    
        let sut = ImagesListPresenter(photos: photos)
        let indexPath = IndexPath(row: 0, section: 0)
        
        //when
        let height = sut.calculateCellHeight(
            indexPath: indexPath,
            viewWidth: 50,
            topInset: 5,
            bottomInset: 5
        )
        
        //then
        XCTAssertNil(height)
    }
    
    func testIsValidIndexPath() {
        //given
        let photos = self.photos
        let sut = ImagesListPresenter(photos: photos)
        let validIndexPath = IndexPath(row: 1, section: 0)
        let invalidIndexPath = IndexPath(row: 2, section: 0)
        
        //when
        let validAnswer = sut.isValidIndexPath(validIndexPath)
        let invalidAnswer = sut.isValidIndexPath(invalidIndexPath)
        
        //then
        XCTAssertTrue(validAnswer)
        XCTAssertFalse(invalidAnswer)
    }
    
    func testObservation() throws {
        //given
        let sut = ImagesListPresenter()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = sut
        sut.view = viewController
        viewController.expectation = expectation(description: "updateTableViewAnimated() should be called")
        
        //when
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //then
        let expectation = try XCTUnwrap(viewController.expectation, "expectation returns nil")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    // MARK: - ImagesListViewController Tests
    
    func testDownloadPhotosCallsWhenViewDidLoad() {
        //given
        let sut = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        sut.presenter = presenter
        presenter.view = sut
        
        //when
        _ = sut.view
        
        //then
        XCTAssertTrue(presenter.downloadPhotosCalled)
    }
    
    func testUpdateTableViewAnimatedCallsGetNewIndexPaths() {
        //given
        let sut = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        sut.presenter = presenter
        presenter.view = sut
        
        //when
        sut.updateTableViewAnimated()
        
        //then
        XCTAssertTrue(presenter.getNewIndexPathsCalled)
    }
    
}
