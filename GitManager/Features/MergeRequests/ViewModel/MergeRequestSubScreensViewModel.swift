//
//  MergeRequestSubScreensViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

/// Fichiers modifiés d'une merge request.
@MainActor
class MergeRequestChangesViewModel: ObservableObject {
    @Published var diffs: [GitLabDiff] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var collapsedFiles: Set<String> = []
    
    var additions: Int { diffs.reduce(0) { $0 + $1.additions } }
    var deletions: Int { diffs.reduce(0) { $0 + $1.deletions } }
    
    func load(project: GitLabProject, mergeRequest: GitLabMergeRequest, user: GitUser) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            diffs = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.mergeRequestDiffs(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    iid: mergeRequest.iid
                )
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            errorMessage = error.gitLabMessage
        }
    }
    
    func toggle(_ file: GitLabDiff) {
        if collapsedFiles.contains(file.id) {
            collapsedFiles.remove(file.id)
        } else {
            collapsedFiles.insert(file.id)
        }
    }
}

/// Commits d'une merge request.
@MainActor
class MergeRequestCommitsViewModel: ObservableObject {
    @Published var commits: [GitLabCommit] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    func load(project: GitLabProject, mergeRequest: GitLabMergeRequest, user: GitUser) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            commits = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.mergeRequestCommits(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    iid: mergeRequest.iid
                )
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            errorMessage = error.gitLabMessage
        }
    }
}
