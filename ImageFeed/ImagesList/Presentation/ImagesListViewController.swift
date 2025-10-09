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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
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
        imagesListService = ImagesListService()
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
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            switch result {
            case .success(_):
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
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
        singleImageViewController.image = UIImage(resource: ._0)
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
        
        print("oldCount = \(oldCount), newCount = \(newCount)")
        print("ids: \(photos.map { $0.id })")
        
        if oldCount != newCount {
            imagesTableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                imagesTableView.insertRows(at: indexPaths, with: .automatic)
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

extension ImagesListViewController: ImagesListCellDelegate {
    
    func reloadRow(for cell: ImagesListCell) {
        guard let indexPath = imagesTableView.indexPath(for: cell) else { return }
        imagesTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
