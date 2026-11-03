//
//  CreateMergeRequestViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

enum MergeRequestBranchSheet: Identifiable {
    case base
    case compare
    
    var id: Self { self }
}

/// État du formulaire « Comparer les branches » : choix des branches et aperçu des changements.
@MainActor
class CreateMergeRequestViewModel: ObservableObject {
    @Published var branches: [GitLabBranch] = []
    @Published var baseBranch: GitLabBranch?
    @Published var compareBranch: GitLabBranch?
    @Published var title = ""
    @Published var branchSheet: MergeRequestBranchSheet?
    
    @Published var comparison: GitLabComparison?
    @Published var isComparing = false
    @Published var loadErrorMessage: String?
    
    private var titleWasEdited = false
    
    var canSubmit: Bool {
        guard let baseBranch, let compareBranch else { return false }
        return baseBranch != compareBranch
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isComparing
    }
    
    var hasChanges: Bool {
        (comparison?.commitsCount ?? 0) > 0
    }
    
    func userEditedTitle() {
        titleWasEdited = true
    }
    
    func loadBranches(project: GitLabProject, user: GitUser) async {
        do {
            let result: [GitLabBranch] = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.branches(baseURL: user.url, token: user.token, projectID: project.id)
            )
            branches = result
            baseBranch = result.first(where: \.isDefault) ?? result.first
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            loadErrorMessage = error.gitLabMessage
        }
    }
    
    func select(_ branch: GitLabBranch, for sheet: MergeRequestBranchSheet, project: GitLabProject, user: GitUser) {
        switch sheet {
        case .base:
            baseBranch = branch
        case .compare:
            compareBranch = branch
            if !titleWasEdited {
                title = Self.title(fromBranch: branch.name)
            }
        }
        branchSheet = nil
        Task { await compare(project: project, user: user) }
    }
    
    /// Aperçu des changements : commits et fichiers présents dans la branche comparée mais pas dans la base.
    func compare(project: GitLabProject, user: GitUser) async {
        comparison = nil
        guard let baseBranch, let compareBranch, baseBranch != compareBranch else { return }
        
        isComparing = true
        loadErrorMessage = nil
        defer { isComparing = false }
        
        do {
            comparison = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.compare(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    from: baseBranch.name,
                    to: compareBranch.name
                )
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            loadErrorMessage = error.gitLabMessage
        }
    }
    
    /// « feature/add-login_form » → « Add login form ».
    private static func title(fromBranch name: String) -> String {
        let last = name.split(separator: "/").last.map(String.init) ?? name
        let words = last.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
        return words.prefix(1).uppercased() + words.dropFirst()
    }
}
