//
//  GitLabProject.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabProject: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let nameWithNamespace: String
    let description: String?
    let webURL: URL
    let avatarURL: URL?
    let starCount: Int
    let forksCount: Int
    let visibility: String?
    let lastActivityAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, visibility
        case nameWithNamespace = "name_with_namespace"
        case webURL = "web_url"
        case avatarURL = "avatar_url"
        case starCount = "star_count"
        case forksCount = "forks_count"
        case lastActivityAt = "last_activity_at"
    }
}
