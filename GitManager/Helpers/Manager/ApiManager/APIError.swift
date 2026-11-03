//
//  APIError.swift
//  git Mobile
//
//  Created by Zakaria Lachkar on 30/10/2024.
//

import Foundation

enum APIError: Error, Hashable, Identifiable {
    case defaultError
    case api(ErrorResponse)
    case custom(message: String)
    
    var id: Self { self }
    
    var code: Int {
        switch self {
        default:
             0
        }
    }
    
    var title: String? {
        switch self {
        default:
            return nil
        }
    }
    
    var message: String {
        switch self {
        case .api(let response):
            return response.message ?? self.localizedDescription
        case .custom(let message):
            return message
        case .defaultError:
            return self.localizedDescription
        }
    }
}

struct ErrorResponse: Codable, Hashable {
    var code: Int?
    var message: String?
}
