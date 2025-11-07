import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    private(set) var downloadPhotosCalled: Bool = false
    private(set) var getNewIndexPathsCalled: Bool = false
    
    weak var view: ImagesListViewControllerProtocol?
    
    func downloadPhotos() {
        downloadPhotosCalled = true
    }
    
    func didSelectPhoto(indexPath: IndexPath) {}
    
    func getNewIndexPaths() -> [IndexPath] {
        getNewIndexPathsCalled = true
        return []
    }
    
    func changeLike(indexPath: IndexPath) {}
    
    func getPhotosCount() -> Int {
        return 0
    }
    
    func getPhoto(indexPath: IndexPath) -> Photo? {
        return nil
    }
    
    func calculateCellHeight(indexPath: IndexPath, viewWidth: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> CGFloat? {
        return nil
    }
    
}
