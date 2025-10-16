import UIKit

final class LoaderView: UIView {
    
    private let gradient = CAGradientLayer()
    private let animationKey = "locationsChange"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
        gradient.cornerRadius = layer.cornerRadius
    }
    
    func animateGradient() {
        self.isHidden = false
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.duration = 2
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientAnimation.fromValue = [0, 1]
        gradientAnimation.toValue = [1, 2]
        gradientAnimation.autoreverses = true
        gradient.add(gradientAnimation, forKey: animationKey)
    }
    
    func stopAnimation() {
        gradient.removeAnimation(forKey: animationKey)
        gradient.removeFromSuperlayer()
        self.isHidden = true
    }
    
    private func addGradient() {
        gradient.locations = [0, 1]
        gradient.colors = [
            UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0).cgColor,
            UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 0.3).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        self.layer.addSublayer(gradient)
        self.backgroundColor = .clear
        self.isHidden = true
    }
    
}

