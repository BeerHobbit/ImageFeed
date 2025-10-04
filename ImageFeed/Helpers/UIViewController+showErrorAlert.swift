import UIKit

extension UIViewController {
    
    func showErrorAlert(
        title: String = "Что-то пошло не так(",
        message: String = "Не удалось войти в систему",
        actionTitle: String = "OK"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: actionTitle, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}
