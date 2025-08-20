import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var backwardButton: UIButton!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction func bacwardButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

