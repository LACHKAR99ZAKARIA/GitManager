//
//  GitLabEndpoint.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

enum GitLabEndpoint: APIEndpoint {
    case currentUser(baseURL: URL, token: String)
    case projects(baseURL: URL, token: String)
    
    var baseURL: URL {
        switch self {
        case .currentUser(let baseURL, _), .projects(let baseURL, _):
            return baseURL
        }
    }
    
    var path: String {
        switch self {
        case .currentUser:
            return "api/v4/user"
        case .projects:
            return "api/v4/projects"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .currentUser, .projects:
            return .get
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .currentUser(_, let token), .projects(_, let token):
            return ["PRIVATE-TOKEN": token]
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .currentUser:
            return nil
        case .projects:
            return [
                "membership": true,
                "order_by": "last_activity_at",
                "sort": "desc",
                "per_page": 50
            ]
        }
    }
}
