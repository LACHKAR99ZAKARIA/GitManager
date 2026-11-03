//
//  GitLabUser.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabUser: Decodable, Hashable {
    let id: Int
    let username: String
    let name: String
    let avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, username, name
        case avatarURL = "avatar_url"
    }
}
