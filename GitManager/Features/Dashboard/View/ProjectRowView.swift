//
//  ProjectRowView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct ProjectRowView: View {
    var project: GitLabProject
    
    var body: some View {
        NavigationLink(value: Route.repository(project)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(Color.principal)
                
                Text(project.nameWithNamespace)
                    .font(.footnote)
                    .foregroundStyle(Color.neutral300)
                
                if let description = project.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Color.principal)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label("\(project.starCount)", systemImage: "star")
                    Label("\(project.forksCount)", systemImage: "arrow.triangle.branch")
                    
                    if let lastActivity {
                        Spacer(minLength: 0)
                        Text(lastActivity)
                    }
                }
                .font(.caption)
                .foregroundStyle(Color.neutral300)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.bg25, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var lastActivity: String? {
        guard let value = project.lastActivityAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value) else { return nil }
        return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
    }
}
