import UIKit

final class ImagesListCell: UITableViewCell {
    
    //MARK: Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    
    
    //MARK: IB Outlets
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    
    //MARK: Private Properties
    
    private let gradientLayer = CAGradientLayer()
    
    
    //MARK: Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configCornerRadius(for: cellImageView)
        setupGradient()
        configShadow(for: likeButton.imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    
    //MARK: Private Methods
    
    private func configCornerRadius(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5393]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configShadow(for imageView: UIImageView?) {
        guard let imageView = imageView else { return }
        imageView.layer.shadowColor = UIColor.ypBlack.cgColor
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowRadius = 4
    }
    
}

