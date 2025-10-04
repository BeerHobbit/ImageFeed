import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Views
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .ypWhite
        return webView
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .bar
        progressView.progress = 0.05
        progressView.progressTintColor = .ypBlack
        progressView.trackTintColor = .ypGray
        return progressView
    }()
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        configUI()
        configConstraints()
        configObservation()
        loadAuthView()
    }
    
    //MARK: - Configure UI
    
    private func configUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    // MARK: - Configure Constraints
    
    private func configConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            ]
        )
    }
    
    // MARK: - Private Methods
    
    private func configDependencies() {
        webView.navigationDelegate = self
    }
    
    private func configObservation() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             }
        )
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: UnsplashURLs.unsplashAuthorizeURLString) else {
            print("❌ [loadAuthView] Failed to generate url component from unsplashAuthorizeURLString")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("❌ [loadAuthView] Failed to generate url from url components")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            print("[code] Failed to find authorization code")
            return nil
        }
    }
    
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}
