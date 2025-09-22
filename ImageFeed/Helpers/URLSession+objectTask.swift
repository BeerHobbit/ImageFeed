import Foundation

extension URLSession {
    
    func objectTask<Model: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<Model, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let taskResult = try decoder.decode(Model.self, from: data)
                    completion(.success(taskResult))
                } catch {
                    print("❌ [objectTask] Decoding error: \(error), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
}
