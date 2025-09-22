import Foundation

extension URLSession {
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [dataTask] Network error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                print("❌ [dataTask] Network error: Unknown URLSession error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            let statusCode = response.statusCode
            guard (200..<300).contains(statusCode) else {
                let requestURL = request.url?.absoluteString ?? "unknown URL"
                print("❌ [dataTask] Network error: Server returned status code \(statusCode) for URL: \(requestURL)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
        }
        
        return task
    }
    
}


