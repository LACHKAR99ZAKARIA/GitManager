//
//  GitLabMergeRequest.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabMergeRequest: Decodable, Identifiable, Hashable {
    let id: Int
    let iid: Int
    let title: String
    let state: String
    let draft: Bool?
    let sourceBranch: String
    let targetBranch: String
    let updatedAt: String?
    let author: Author
    
    struct Author: Decodable, Hashable {
        let name: String
        let username: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, iid, title, state, draft, author
        case sourceBranch = "source_branch"
        case targetBranch = "target_branch"
        case updatedAt = "updated_at"
    }
}

extension GitLabMergeRequest {
    /// Données factices pour le skeleton.
    static let placeholders: [GitLabMergeRequest] = (1...8).map { index in
        GitLabMergeRequest(
            id: -index,
            iid: index,
            title: "Titre de la merge request",
            state: "opened",
            draft: false,
            sourceBranch: "feature/branche",
            targetBranch: "main",
            updatedAt: nil,
            author: Author(name: "Auteur", username: "auteur")
        )
    }
}
