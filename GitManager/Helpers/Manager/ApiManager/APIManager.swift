//
//  APIManager.swift
//  git Mobile
//
//  Created by Zakaria Lachkar on 26/10/2024.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func performRequest<T: Decodable>(for endpoint: APIEndpoint) async throws -> T {
        var urlComponents = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        
        if let parameters = endpoint.parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        if let query = endpoint.query {
            if urlComponents.queryItems == nil {
                urlComponents.queryItems = []
            }
            urlComponents.queryItems?.append(contentsOf: query.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            })
        }
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        print("Request URL: \(urlRequest.url?.absoluteString ?? "")")
        print("HTTP Method: \(urlRequest.httpMethod ?? "")")
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
                print("Header: \(key): \(value)")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from the server."])
        }
        
        print("HTTP Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        let decoder = JSONDecoder()
        let dataDecoded = try decoder.decode(T.self, from: data)
        print(dataDecoded)
        return try decoder.decode(T.self, from: data)
    }
}
