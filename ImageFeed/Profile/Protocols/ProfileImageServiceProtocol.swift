protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    
    func fetchProfileImageURL(_ token: String, username: String, completion: @escaping (Result<String, Error>) -> Void)
}
