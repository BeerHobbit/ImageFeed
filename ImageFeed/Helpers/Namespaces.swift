import Foundation

enum Constants {
    static let accessKey = "zW4zOvYQvnlTEaDikZBRQYAWUQrZcKFsR8iKR1jLIxE"
    static let secretKey = "UwqIy5U2zgVBKw3AZbKOnXVfyVw3purP6KHyqW9aVWk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
}

enum UnsplashURLs {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenRequestURLString = "https://unsplash.com/oauth/token"
    static let unsplashUserProfileURLString = "https://api.unsplash.com/me"
    static let unsplashUserPublicProfileURLString = "https://api.unsplash.com/users/"
    static let unsplashPhotosListString = "https://api.unsplash.com/photos"
}

enum HttpMethods {
    static let get = "GET"
    static let post = "POST"
}
