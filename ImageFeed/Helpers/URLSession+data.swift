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
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("❌ URLRequest error: \(error)")
                return
            }
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("❌ Unknown URLSession error")
                return
            }
            
            let statusCode = response.statusCode
            guard 200..<300 ~= statusCode else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                print("❌ Invalid HTTP status code: \(statusCode)")
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
        }
        
        return task
    }
    
}


