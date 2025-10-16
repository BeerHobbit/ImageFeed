import Foundation

final class ImagesListService {
    
    // MARK: - Singleton
    
    static let shared = ImagesListService()
    
    // MARK: - Notifications
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Public Properties
    
    private(set) var photos: [Photo] = []
    private(set) var lastLoadedPage: Int?
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private var imagesListTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        guard imagesListTask == nil else {
            print("⚠️ [fetchPhotosNextPage] Task already running")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeImagesListRequest(page: nextPage, perPage: 10) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        imagesListTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.imagesListTask = nil }
            
            switch result {
            case .success(let photosResult):
                let newPhotos = photosResult.map { self.makePhoto(from: $0) }
                self.appendUniquePhotos(newPhotos)
                completion(.success(newPhotos))
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        imagesListTask?.resume()
    }
    
    func fetchLike(id: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard likeTask == nil else {
            print("⚠️ [fetchLike] Task already running")
            return
        }
        
        guard let request = makeLikeRequest(id: id, isLike: isLike) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        likeTask = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            defer { self.likeTask = nil }
            
            switch result {
            case .success:
                self.toggleLike(for: id)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        likeTask?.resume()
    }
    
    func resetState() {
        photos = []
        lastLoadedPage = nil
    }
    
    // MARK: - Private Methods
    
    private func makePhoto(from result: PhotoResult) -> Photo {
        Photo(
            id: result.id,
            size: CGSize(width: Double(result.width), height: Double(result.height)),
            createdAt: dateFormatter.date(from: result.createdAt),
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            smallImageURL: result.urls.small,
            regularImageURL: result.urls.regular,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    private func appendUniquePhotos(_ newPhotos: [Photo]) {
        let existingIds = Set(photos.map(\.id))
        let unique = newPhotos.filter { !existingIds.contains($0.id) }
        photos.append(contentsOf: unique)
        lastLoadedPage = (lastLoadedPage ?? 0) + 1
    }
    
    private func toggleLike(for id: String) {
        guard let index = photos.firstIndex(where: { $0.id == id }) else { return }
        var photo = photos[index]
        photo = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            smallImageURL: photo.smallImageURL,
            regularImageURL: photo.regularImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked
        )
        photos[index] = photo
    }
    
    private func makeImagesListRequest(page: Int, perPage: Int) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            var components = URLComponents(string: UnsplashURLs.unsplashPhotosListString)
        else {
            assertionFailure("❌[makeImagesListRequest] Invalid URL for images list request")
            return nil
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(id: String, isLike: Bool) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = URL(string: UnsplashURLs.unsplashPhotosListString + "\(id)/like")
        else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HttpMethods.post : HttpMethods.delete
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}
