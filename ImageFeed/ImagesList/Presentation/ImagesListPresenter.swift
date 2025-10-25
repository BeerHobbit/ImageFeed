import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - View
    
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private var imagesListService: ImagesListServiceProtocol?
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init() {
        configDependencies()
        setupObserver()
    }
    
    func downloadPhotos() {
        view?.showLoadingIndicator(isBlockingUI: false)
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            guard let self = self else {
                self?.view?.hideLoadingIndicator()
                return
            }
            switch result {
            case .success(_):
                break
            case .failure(_):
                view?.presentErrorAlert()
            }
            view?.hideLoadingIndicator()
        }
    }
    
    func didSelectPhoto(indexPath: IndexPath) {
        guard indexPath.row < photos.count,
              let imageURL = URL(string: photos[indexPath.row].largeImageURL)
        else {
            print("❌ [didSelectPhoto] incorrect image URL")
            return
        }
        view?.presentSingleImageScreen(url: imageURL)
    }
    
    func getNewIndexPaths() -> [IndexPath] {
        guard let imagesListService = imagesListService else { return [] }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        guard oldCount != newCount else { return [] }
        let indexPaths = (oldCount..<newCount).map { i in
            IndexPath(row: i, section: 0)
        }
        return indexPaths
    }
    
    func changeLike(indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let id = photo.id
        let isLike = !photo.isLiked
        view?.showLoadingIndicator(isBlockingUI: true)
        
        imagesListService?.fetchLike(id: id, isLike: isLike) { [weak self] result in
            guard let self = self else {
                self?.view?.hideLoadingIndicator()
                return
            }
            switch result {
            case .success(()):
                guard let servicePhotos = self.imagesListService?.photos else {
                    view?.hideLoadingIndicator()
                    return
                }
                self.photos = servicePhotos
                let updatedPhoto = self.photos[indexPath.row]
                view?.updateLikeState(indexPath: indexPath, isLiked: updatedPhoto.isLiked)
            case .failure(let error):
                print("❌ [changeLike] Like was not updated for photo ID: \(id), error: \(error)")
                self.view?.presentErrorAlert()
            }
            self.view?.hideLoadingIndicator()
        }
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func getPhoto(indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func calculateCellHeight(indexPath: IndexPath, viewWidth: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> CGFloat? {
        let photoSize = getPhotoSize(indexPath: indexPath)
        guard photoSize.width > 0, photoSize.height > 0 else { return nil }
        let imageWidth = photoSize.width
        let imageHeight = photoSize.height
        let scale = viewWidth / imageWidth
        let cellHeight = imageHeight * scale + topInset + bottomInset
        return cellHeight
    }
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.view?.updateTableViewAnimated()
        }
    }
    
    private func getPhotoSize(indexPath: IndexPath) -> CGSize {
        return photos[indexPath.row].size
    }
    
    private func configDependencies() {
        imagesListService = ImagesListService.shared
    }
    
}
