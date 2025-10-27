import Foundation
@testable import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    
    private(set) var fetchPhotosNextPageCalled: Bool = false
    private(set) var fetchLikeCalled: Bool = false
    
    var photos: [Photo] = []
    var lastLoadedPage: Int?
    
    func fetchPhotosNextPage(completion: @escaping (Result<[ImageFeed.Photo], any Error>) -> Void) {
        fetchPhotosNextPageCalled = true
    }
    
    func fetchLike(id: String, isLike: Bool, completion: @escaping (Result<Void, any Error>) -> Void) {
        fetchLikeCalled = true
    }
    
}
