import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func showLoadingIndicator(isBlockingUI: Bool)
    func hideLoadingIndicator()
    func presentSingleImageScreen(url: URL)
    func updateTableViewAnimated()
    func updateLikeState(indexPath: IndexPath, isLiked: Bool)
    func presentErrorAlert()
}
