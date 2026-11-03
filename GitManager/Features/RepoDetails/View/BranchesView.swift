//
//  BranchesView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct BranchesView: View {
    var branches: [GitLabBranch]
    var selectedBranch: String?
    var onSelect: (GitLabBranch) -> Void
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Branches")
                    .font(.title2.bold())
                    .foregroundStyle(Color.principal)
                
                if branches.isEmpty {
                    Text("Aucune branche disponible")
                        .font(.footnote)
                        .foregroundStyle(Color.neutral300)
                }
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(branches) { branch in
                            row(for: branch)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func row(for branch: GitLabBranch) -> some View {
        Button {
            onSelect(branch)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.branch")
                    .foregroundStyle(Color.neutral300)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(branch.name)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.principal)
                    
                    if let badges = badges(for: branch) {
                        Text(badges)
                            .font(.caption)
                            .foregroundStyle(Color.neutral300)
                    }
                }
                
                Spacer(minLength: 0)
                
                if branch.name == selectedBranch {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.principal)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(in: RoundedRectangle(cornerRadius: 12), interactive: true)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func badges(for branch: GitLabBranch) -> String? {
        let labels = [
            branch.isDefault ? "Par défaut" : nil,
            branch.isProtected ? "Protégée" : nil
        ].compactMap { $0 }
        return labels.isEmpty ? nil : labels.joined(separator: " · ")
    }
}

#Preview {
    BranchesView(
        branches: [
            GitLabBranch(name: "main", isDefault: true, isProtected: true),
            GitLabBranch(name: "feature/x", isDefault: false, isProtected: false)
        ],
        selectedBranch: "main",
        onSelect: { _ in }
    )
}
