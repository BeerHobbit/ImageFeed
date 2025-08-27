import UIKit

final class ImagesListCell: UITableViewCell {
    
    //MARK: - Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    
    
    //MARK: - IB Outlets
    
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    
    
    //MARK: - Private Properties
    
    private let gradientLayer = CAGradientLayer()
    
    
    //MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configCellUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    
    //MARK: - Cell Configuration Method
    
    func configure(image: UIImage?, date: String, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    //MARK: - UI Configuration Methods
    
    private func configCellUI() {
        configCornerRadius(for: cellImageView)
        configGradient()
        configShadow(for: likeButton.imageView)
    }
    
    private func configCornerRadius(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    private func configGradient() {
        let startColor = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let endColor = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        
        gradientLayer.colors = [startColor, endColor]
        gradientLayer.locations = [0.0, 0.5]
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

