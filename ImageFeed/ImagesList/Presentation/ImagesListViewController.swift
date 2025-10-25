import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - Presenter
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Views
    
    private let imagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Private Properties
    
    private let defaultCellHeight: CGFloat = 300
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        getPhotos()
    }
    
    // MARK: - ImagesListViewControllerProtocol
    
    func showLoadingIndicator(isBlockingUI: Bool) {
        UIBlockingProgressHUD.show(isBlockingUI: isBlockingUI)
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func presentSingleImageScreen(url: URL) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageURL = url
        singleImageViewController.modalPresentationStyle = .fullScreen
        singleImageViewController.modalTransitionStyle = .crossDissolve
        present(singleImageViewController, animated: true)
    }
    
    func updateTableViewAnimated() {
        guard let indexPaths = presenter?.getNewIndexPaths(),
              !indexPaths.isEmpty else { return }
        imagesTableView.performBatchUpdates {
            imagesTableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func updateLikeState(indexPath: IndexPath, isLiked: Bool) {
        guard let cell = imagesTableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.photoIsLiked = isLiked
    }
    
    func presentErrorAlert() {
        showErrorAlert()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
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
    
    private func getPhotos() {
        presenter?.downloadPhotos()
    }
    
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.getPhotosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell,
              let photo = presenter?.getPhoto(indexPath: indexPath)
        else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        imageListCell.configureCell(photo: photo)
        
        return imageListCell
    }
    
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectPhoto(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard let cellHeight = presenter?.calculateCellHeight(
            indexPath: indexPath,
            viewWidth: imageViewWidth,
            topInset: imageInsets.top,
            bottomInset: imageInsets.bottom
        ) else { return defaultCellHeight }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter?.getPhotosCount() {
            getPhotos()
        }
    }
    
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func likeButtonInCellDidTap(_ cell: ImagesListCell) {
        guard let indexPath = imagesTableView.indexPath(for: cell) else { return }
        presenter?.changeLike(indexPath: indexPath)
    }
    
}
