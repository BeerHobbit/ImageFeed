import UIKit

final class SingleImageViewController: UIViewController {
    
    //MARK: - IB Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    
    //MARK: - Public Properties
    
    var image: UIImage?
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configScrollView()
        configImageInScrollView()
    }
    
    
    //MARK: - Private Methods
    
    private func configScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
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
    
    
    //MARK: - IB Actions
    
    @IBAction func didTapBackwardButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        presentShareMenu()
    }
    
}


//MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
}
