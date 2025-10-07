import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Views
    
    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .likeButtonOff)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        return label
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Private Properties
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let startColor = UIColor.ypBlack.withAlphaComponent(0.0).cgColor
        let endColor = UIColor.ypBlack.withAlphaComponent(0.2).cgColor
        layer.colors = [startColor, endColor]
        layer.locations = [0.0, 0.5]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCellUI()
        configConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("❌ [ImagesListCell.init] init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Cell Configuration Public Method
    
    func configure(image: UIImage?, date: String, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Configure UI
    
    private func configCellUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cellImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        contentView.insertSubview(gradientView, belowSubview: dateLabel)
        insertGradient()
        configShadowForLikeButton()
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
                
                likeButton.widthAnchor.constraint(equalToConstant: 44),
                likeButton.heightAnchor.constraint(equalToConstant: 44),
                likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
                likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
                
                gradientView.heightAnchor.constraint(equalToConstant: 30),
                gradientView.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
                gradientView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
                gradientView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor),
                
                dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
                dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImageView.trailingAnchor, constant: -8),
                dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8)
            ]
        )
    }
    
    // MARK: - Private Methods
    
    private func insertGradient() {
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configShadowForLikeButton() {
        guard let imageView = likeButton.imageView else { return }
        imageView.layer.shadowColor = UIColor.ypBlack.cgColor
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowRadius = 4
    }
    
}

