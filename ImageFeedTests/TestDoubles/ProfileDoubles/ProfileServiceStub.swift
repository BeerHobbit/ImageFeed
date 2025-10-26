import Foundation
@testable import ImageFeed

final class ProfileServiceStub: ProfileServiceProtocol {
    
    var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.Profile, any Error>) -> Void) {}
    
}
