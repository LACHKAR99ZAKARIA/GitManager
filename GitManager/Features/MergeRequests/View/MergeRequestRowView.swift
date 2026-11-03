//
//  MergeRequestRowView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct MergeRequestRowView: View {
    var mergeRequest: GitLabMergeRequest
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(icon.color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.body)
                    .foregroundStyle(Color.principal)
                    .multilineTextAlignment(.leading)
                
                Text("@\(mergeRequest.author.username) · \(mergeRequest.sourceBranch) → \(mergeRequest.targetBranch)")
                    .font(.caption)
                    .foregroundStyle(Color.neutral300)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            if let updatedAt {
                Text(updatedAt)
                    .font(.subheadline)
                    .foregroundStyle(Color.neutral300)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    private var titleText: String {
        "\(mergeRequest.draft == true ? "[Draft] " : "")\(mergeRequest.title) #\(mergeRequest.iid)"
    }
    
    private var icon: (name: String, color: Color) {
        switch mergeRequest.state {
        case "merged":
            return ("arrow.triangle.merge", .purple)
        case "closed":
            return ("arrow.triangle.pull", .red)
        default:
            return ("arrow.triangle.pull", .green)
        }
    }
    
    private var updatedAt: String? {
        guard let value = mergeRequest.updatedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value) else { return nil }
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .abbreviated
        return relative.localizedString(for: date, relativeTo: Date())
    }
}
