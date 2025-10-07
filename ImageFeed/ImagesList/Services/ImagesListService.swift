import Foundation

final class ImagesListService {
    
    // MARK: - Notifications
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var imagesListTask: URLSessionTask?
    private lazy var dateFormatter = ISO8601DateFormatter()
    
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
            print("❌ [makeProfileImageRequest] Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
                
            case .success(let photosResult):
                var photos: [Photo] = []
                photosResult.forEach { photoResult in
                    let width = Double(photoResult.width)
                    let height = Double(photoResult.height)
                    let date = self.dateFormatter.date(from: photoResult.createdAt)
                    
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: width, height: height),
                        createdAt: date,
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                    photos.append(photo)
                }
                self.photos += photos
                lastLoadedPage = (lastLoadedPage ?? 0) + 1
                completion(.success(photos))
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photos": photos]
                )
                
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.imagesListTask = nil
        }
        
        self.imagesListTask = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeImagesListRequest(page: Int, perPage: Int) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = Constants.defaultBaseURL?.appendingPathComponent(UnsplashPaths.photos),
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
    
}

