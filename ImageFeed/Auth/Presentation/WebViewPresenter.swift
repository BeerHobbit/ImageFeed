import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
  
    // MARK: - View
    
    weak var view: WebViewViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private var authHelper: AuthHelperProtocol
    
    // MARK: - Initializer
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        loadAuthView()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    // MARK: - Private Methods
    
    private func loadAuthView() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
    }
    
}

