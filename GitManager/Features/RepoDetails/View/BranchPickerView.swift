//
//  BranchPickerView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Sheet « Choisir une branche » : liste de branches en pastilles monospace séparées par des traits,
/// avec une barre de recherche en bas.
struct BranchPickerView: View {
    var title: String
    var branches: [GitLabBranch]
    var selectedName: String?
    var onSelect: (GitLabBranch) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private var filteredBranches: [GitLabBranch] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return branches }
        return branches.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                Rectangle()
                    .fill(Color.neutral200.opacity(0.6))
                    .frame(height: 1)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if filteredBranches.isEmpty {
                            Text("Aucune branche trouvée")
                                .font(.footnote)
                                .foregroundStyle(Color.neutral300)
                                .padding(.top, 24)
                        }
                        
                        ForEach(filteredBranches) { branch in
                            row(for: branch)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                searchBar
            }
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        ZStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.principal)
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                        .frame(width: 44, height: 44)
                        .glassBackground(in: Circle(), interactive: true)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private func row(for branch: GitLabBranch) -> some View {
        VStack(spacing: 0) {
            Button {
                onSelect(branch)
            } label: {
                HStack(spacing: 12) {
                    Text(branch.name)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.principal)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.neutral200.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.neutral200, lineWidth: 1)
                        )
                    
                    Spacer(minLength: 0)
                    
                    if branch.name == selectedName {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.principal)
                    }
                }
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Rectangle()
                .fill(Color.neutral200.opacity(0.6))
                .frame(height: 1)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.neutral300)
            
            TextField("Rechercher une branche", text: $searchText)
                .foregroundStyle(Color.principal)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassBackground(in: Capsule())
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

#Preview {
    BranchPickerView(
        title: "Choisir une branche",
        branches: [
            GitLabBranch(name: "main", isDefault: true, isProtected: true),
            GitLabBranch(name: "fix/resource-links", isDefault: false, isProtected: false),
            GitLabBranch(name: "remove/dead-cheatsheet-app-link", isDefault: false, isProtected: false)
        ],
        selectedName: "main",
        onSelect: { _ in }
    )
}
