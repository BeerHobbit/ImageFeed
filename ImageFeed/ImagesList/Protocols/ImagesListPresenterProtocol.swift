import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func downloadPhotos()
    func didSelectPhoto(indexPath: IndexPath)
    func getNewIndexPaths() -> [IndexPath]
    func changeLike(indexPath: IndexPath)
    func getPhotosCount() -> Int
    func getPhoto(indexPath: IndexPath) -> Photo?
    func calculateCellHeight(indexPath: IndexPath, viewWidth: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> CGFloat?
}
