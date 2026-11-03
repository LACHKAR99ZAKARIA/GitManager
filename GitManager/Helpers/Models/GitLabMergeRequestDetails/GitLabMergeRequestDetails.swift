//
//  GitLabMergeRequestDetails.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

struct GitLabUserRef: Decodable, Hashable {
    let name: String
    let username: String
    let avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name, username
        case avatarURL = "avatar_url"
    }
}

/// Réponse de `GET /projects/:id/merge_requests/:iid`.
struct GitLabMergeRequestDetails: Decodable {
    let description: String?
    let createdAt: String?
    let mergedAt: String?
    let webURL: URL?
    let author: GitLabUserRef?
    let reviewers: [GitLabUserRef]?
    let headPipeline: Pipeline?
    let detailedMergeStatus: String?
    let hasConflicts: Bool?
    
    struct Pipeline: Decodable {
        let status: String
    }
    
    enum CodingKeys: String, CodingKey {
        case description, author, reviewers
        case createdAt = "created_at"
        case mergedAt = "merged_at"
        case webURL = "web_url"
        case headPipeline = "head_pipeline"
        case detailedMergeStatus = "detailed_merge_status"
        case hasConflicts = "has_conflicts"
    }
}

struct GitLabCommit: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let authorName: String
    let committerName: String?
    let committedDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case authorName = "author_name"
        case committerName = "committer_name"
        case committedDate = "committed_date"
    }
}

struct GitLabNote: Decodable, Identifiable, Hashable {
    let id: Int
    let body: String
    let author: GitLabUserRef
    let createdAt: String?
    let system: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, body, author, system
        case createdAt = "created_at"
    }
}

struct GitLabDiff: Decodable, Identifiable {
    let oldPath: String
    let newPath: String
    let diff: String
    let newFile: Bool?
    let deletedFile: Bool?
    let renamedFile: Bool?
    
    var id: String { "\(oldPath)->\(newPath)" }
    
    enum CodingKeys: String, CodingKey {
        case diff
        case oldPath = "old_path"
        case newPath = "new_path"
        case newFile = "new_file"
        case deletedFile = "deleted_file"
        case renamedFile = "renamed_file"
    }
    
    var lines: [DiffLine] { DiffLine.parse(diff) }
    var additions: Int { lines.filter { $0.kind == .added }.count }
    var deletions: Int { lines.filter { $0.kind == .removed }.count }
}

struct DiffLine: Identifiable {
    enum Kind {
        case hunk, context, added, removed
    }
    
    let id: Int
    let kind: Kind
    let oldNumber: Int?
    let newNumber: Int?
    let text: String
    
    /// Découpe un diff unifié (`@@ -a,b +c,d @@`) en lignes numérotées.
    static func parse(_ diff: String) -> [DiffLine] {
        let hunkRegex = try? NSRegularExpression(pattern: #"^@@ -(\d+)(?:,\d+)? \+(\d+)"#)
        var oldNumber = 0
        var newNumber = 0
        var result: [DiffLine] = []
        
        for rawLine in diff.components(separatedBy: "\n") {
            let index = result.count
            
            if rawLine.hasPrefix("@@") {
                let range = NSRange(rawLine.startIndex..., in: rawLine)
                if let match = hunkRegex?.firstMatch(in: rawLine, range: range),
                   let oldRange = Range(match.range(at: 1), in: rawLine),
                   let newRange = Range(match.range(at: 2), in: rawLine) {
                    oldNumber = Int(rawLine[oldRange]) ?? 0
                    newNumber = Int(rawLine[newRange]) ?? 0
                }
                result.append(DiffLine(id: index, kind: .hunk, oldNumber: nil, newNumber: nil, text: rawLine))
            } else if rawLine.hasPrefix("+") {
                result.append(DiffLine(id: index, kind: .added, oldNumber: nil, newNumber: newNumber, text: String(rawLine.dropFirst())))
                newNumber += 1
            } else if rawLine.hasPrefix("-") {
                result.append(DiffLine(id: index, kind: .removed, oldNumber: oldNumber, newNumber: nil, text: String(rawLine.dropFirst())))
                oldNumber += 1
            } else if rawLine.hasPrefix("\\") || rawLine.isEmpty {
                continue
            } else {
                result.append(DiffLine(id: index, kind: .context, oldNumber: oldNumber, newNumber: newNumber, text: String(rawLine.dropFirst())))
                oldNumber += 1
                newNumber += 1
            }
        }
        return result
    }
}
