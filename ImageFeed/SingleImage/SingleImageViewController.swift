import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var image: UIImage?
    
    // MARK: - Views
    
    private let scrollView = UIScrollView()
    
    private let imageView = UIImageView()
    
    private let backwardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .navBackButton)
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .shareButton)
        button.setImage(image, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        configActions()
        configScrollView()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        scrollView.delegate = self
    }
    
    // MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        view.addSubview(backwardButton)
        view.addSubview(shareButton)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                backwardButton.widthAnchor.constraint(equalToConstant: 24),
                backwardButton.heightAnchor.constraint(equalToConstant: 24),
                backwardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
                backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
                
                shareButton.widthAnchor.constraint(equalToConstant: 50),
                shareButton.heightAnchor.constraint(equalToConstant: 50),
                shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17)
            ]
        )
    }
    
    // MARK: - Configure Actions
    
    private func configActions() {
        backwardButton.addTarget(self, action: #selector(didTapBackwardButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapBackwardButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapShareButton() {
        presentShareMenu()
    }
    
    // MARK: - Private Methods
    
    private func configScrollView() {
        scrollView.addSubview(imageView)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        configImageInScrollView()
    }
    
    private func configImageInScrollView() {
        guard let image = image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func  rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.minimumZoomScale = scale
        scrollView.layoutIfNeeded()
        centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let y = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
    
    private func presentShareMenu() {
        guard let image = image else { return }
        let shareMenu = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        shareMenu.overrideUserInterfaceStyle = .dark
        present(shareMenu, animated: true, completion: nil)
    }
    
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
}
