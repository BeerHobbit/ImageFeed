import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Views
    
    private let imagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Private Properties
    
    private var imagesListService: ImagesListService?
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        downloadPhotos()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        imagesListService = ImagesListService.shared
        setupObserver()
        imagesTableView.dataSource = self
        imagesTableView.delegate = self
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(imagesTableView)
    }
    
    // MARK: - Config Constraints
    
    private func configConstraints() {
        imagesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                imagesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imagesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imagesTableView.topAnchor.constraint(equalTo: view.topAnchor),
                imagesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    // MARK: - Private Methods
    
    private func downloadPhotos() {
        UIBlockingProgressHUD.show(isBlockingUI: false)
        imagesListService?.fetchPhotosNextPage { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else {
                return
            }
            switch result {
            case .success(_):
                break
            case .failure(_):
                self.showErrorAlert()
            }
        }
    }
    
    private func presentSingleImageViewController(indexPath: IndexPath) {
        guard let imageURL = URL(string: photos[indexPath.row].largeImageURL) else {
            print("❌ [presentSingleImageViewController] incorrect image URL")
            return
        }
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageURL = imageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        singleImageViewController.modalTransitionStyle = .crossDissolve
        present(singleImageViewController, animated: true)
    }
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        guard let imagesListService = imagesListService else { return }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            imagesTableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                imagesTableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func changeLike(cell: ImagesListCell) {
        guard let indexPath = imagesTableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let id = photo.id
        let isLike = !photo.isLiked
        UIBlockingProgressHUD.show(isBlockingUI: true)
        
        imagesListService?.fetchLike(id: id, isLike: isLike) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            switch result {
            case .success(()):
                guard let servicePhotos = self.imagesListService?.photos else { return }
                self.photos = servicePhotos
                cell.photoIsLiked = self.photos[indexPath.row].isLiked
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("❌ [changeLike] Like was not updated for photo ID: \(id), error: \(error)")
                self.showErrorAlert()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        imageListCell.delegate = self
        imageListCell.configureCell(photo: photo)
        
        return imageListCell
    }
    
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentSingleImageViewController(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
 
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
 
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
 
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            downloadPhotos()
        }
    }
    
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func likeButtonInCellDidTap(_ cell: ImagesListCell) {
        changeLike(cell: cell)
    }
    
}
