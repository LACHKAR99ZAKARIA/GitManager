//
//  GitLabComparison.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

/// Réponse de `GET /projects/:id/repository/compare`.
struct GitLabComparison: Decodable {
    let commits: [GitLabListItem]?
    let diffs: [GitLabListItem]?
    let compareSameRef: Bool?
    
    var commitsCount: Int { commits?.count ?? 0 }
    var filesCount: Int { diffs?.count ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case commits, diffs
        case compareSameRef = "compare_same_ref"
    }
}
