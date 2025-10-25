protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    var lastLoadedPage: Int? { get }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func fetchLike(id: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}
