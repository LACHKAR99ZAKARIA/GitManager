//
//  GitLabBranch.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabBranch: Decodable, Identifiable, Hashable {
    let name: String
    let isDefault: Bool
    let isProtected: Bool
    
    var id: String { name }
    
    enum CodingKeys: String, CodingKey {
        case name
        case isDefault = "default"
        case isProtected = "protected"
    }
}
