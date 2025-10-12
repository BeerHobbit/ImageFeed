import Foundation

final class ImagesListService {
    
    // MARK: - Singleton
    
    static let shared = ImagesListService()
    
    // MARK: - Notifications
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Public Properties
    
    var photos: [Photo] = []
    var lastLoadedPage: Int?
    
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
            print("[fetchPhotosNextPage] Task already exists")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let imagesPerPage = 10
        guard let request = makeImagesListRequest(page: nextPage, perPage: imagesPerPage) else {
            print("❌ [fetchPhotosNextPage] Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photosResult):
                var newPhotos: [Photo] = photosResult.map { photoResult in
                    let date = self.dateFormatter.date(from: photoResult.createdAt)
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: Double(photoResult.width), height: Double(photoResult.height)),
                        createdAt: date,
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        smallImageURL: photoResult.urls.small,
                        regularImageURL: photoResult.urls.regular,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                    return photo
                }
                let photoIds = Set(self.photos.map {$0.id})
                let uniqueNewPhotos = newPhotos.filter { !photoIds.contains($0.id) }
                self.photos.append(contentsOf: uniqueNewPhotos)
                lastLoadedPage = (lastLoadedPage ?? 0) + 1
                completion(.success(uniqueNewPhotos))
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: nil
                )
                
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.imagesListTask = nil
        }
        
        self.imagesListTask = task
        task.resume()
    }
    
    func fetchLike(id: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard likeTask == nil else {
            print("[fetchLike] Task already exists")
            return
        }
        
        guard let request = makeLikeRequest(id: id, isLike: isLike) else {
            print("❌ [fetchLike] Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == id }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
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
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
            self.likeTask = nil
        }
        
        self.likeTask = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeImagesListRequest(page: Int, perPage: Int) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = URL(string: UnsplashURLs.unsplashPhotosListString),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            assertionFailure("❌ [makeImagesListRequest] Incorrect request URL")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let requestURL = urlComponents.url else {
            print("❌ [makeImagesListRequest] Incorrect request URL with parameters")
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HttpMethods.get
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(id: String, isLike: Bool) -> URLRequest? {
        let urlString = UnsplashURLs.unsplashPhotosListString + id + "/like"
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = URL(string: urlString) else {
            print("❌ [makePostLikeRequest] Incorrect request URL, photo ID: \(id)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HttpMethods.post : HttpMethods.delete
        print("[makeLikeRequest] Request method is \(request.httpMethod ?? "nil")")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}

