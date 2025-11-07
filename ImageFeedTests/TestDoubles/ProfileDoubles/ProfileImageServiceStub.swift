import Foundation
@testable import ImageFeed

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    
    var avatarURL: String?
    
    func fetchProfileImageURL(_ token: String, username: String, completion: @escaping (Result<String, any Error>) -> Void) {}
    
}
