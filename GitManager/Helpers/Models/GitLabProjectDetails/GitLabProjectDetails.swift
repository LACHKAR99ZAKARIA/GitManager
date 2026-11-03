//
//  GitLabProjectDetails.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabProjectDetails: Decodable {
    let defaultBranch: String?
    let openIssuesCount: Int?
    let license: License?
    let statistics: Statistics?
    
    struct License: Decodable {
        let name: String
    }
    
    struct Statistics: Decodable {
        let commitCount: Int
        
        enum CodingKeys: String, CodingKey {
            case commitCount = "commit_count"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case license, statistics
        case defaultBranch = "default_branch"
        case openIssuesCount = "open_issues_count"
    }
}

/// Élément minimal d'une liste (merge requests, contributeurs) : on n'en utilise que le nombre.
struct GitLabListItem: Decodable {}

/// Élément de `GET /projects/:id/starrers`.
struct GitLabStarrer: Decodable {
    let user: User
    
    struct User: Decodable {
        let username: String
    }
}

/// Réponse de `POST /projects/:id/star` et `/unstar` : le projet mis à jour.
struct GitLabStarResult: Decodable {
    let starCount: Int
    
    enum CodingKeys: String, CodingKey {
        case starCount = "star_count"
    }
}
