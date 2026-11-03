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
    case projectDetails(baseURL: URL, token: String, projectID: Int)
    case mergeRequests(baseURL: URL, token: String, projectID: Int)
    case contributors(baseURL: URL, token: String, projectID: Int)
    case mergeRequestList(baseURL: URL, token: String, projectID: Int, state: MergeRequestState)
    case branches(baseURL: URL, token: String, projectID: Int)
    /// Utilisateurs ayant mis une étoile, filtrés par `search` (nom d'utilisateur).
    case starrers(baseURL: URL, token: String, projectID: Int, search: String)
    case star(baseURL: URL, token: String, projectID: Int)
    case unstar(baseURL: URL, token: String, projectID: Int)
    
    private var access: (baseURL: URL, token: String) {
        switch self {
        case .currentUser(let baseURL, let token),
             .projects(let baseURL, let token),
             .projectDetails(let baseURL, let token, _),
             .mergeRequests(let baseURL, let token, _),
             .mergeRequestList(let baseURL, let token, _, _),
             .contributors(let baseURL, let token, _),
             .branches(let baseURL, let token, _),
             .starrers(let baseURL, let token, _, _),
             .star(let baseURL, let token, _),
             .unstar(let baseURL, let token, _):
            return (baseURL, token)
        }
    }
    
    var baseURL: URL {
        access.baseURL
    }
    
    var path: String {
        switch self {
        case .currentUser:
            return "api/v4/user"
        case .projects:
            return "api/v4/projects"
        case .projectDetails(_, _, let projectID):
            return "api/v4/projects/\(projectID)"
        case .mergeRequests(_, _, let projectID):
            return "api/v4/projects/\(projectID)/merge_requests"
        case .mergeRequestList(_, _, let projectID, _):
            return "api/v4/projects/\(projectID)/merge_requests"
        case .contributors(_, _, let projectID):
            return "api/v4/projects/\(projectID)/repository/contributors"
        case .branches(_, _, let projectID):
            return "api/v4/projects/\(projectID)/repository/branches"
        case .starrers(_, _, let projectID, _):
            return "api/v4/projects/\(projectID)/starrers"
        case .star(_, _, let projectID):
            return "api/v4/projects/\(projectID)/star"
        case .unstar(_, _, let projectID):
            return "api/v4/projects/\(projectID)/unstar"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .star, .unstar:
            return .post
        default:
            return .get
        }
    }
    
    var headers: [String: String]? {
        ["PRIVATE-TOKEN": access.token]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .projects:
            return [
                "membership": true,
                "order_by": "last_activity_at",
                "sort": "desc",
                "per_page": 50
            ]
        case .projectDetails:
            return ["statistics": true, "license": true]
        case .mergeRequests:
            return ["state": "opened", "per_page": 100]
        case .mergeRequestList(_, _, _, let state):
            return ["state": state.rawValue, "order_by": "updated_at", "sort": "desc", "per_page": 100]
        case .contributors, .branches:
            return ["per_page": 100]
        case .starrers(_, _, _, let search):
            return ["search": search, "per_page": 100]
        case .currentUser, .star, .unstar:
            return nil
        }
    }
}
