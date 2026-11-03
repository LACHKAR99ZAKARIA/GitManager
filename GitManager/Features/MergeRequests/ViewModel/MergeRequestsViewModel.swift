//
//  MergeRequestsViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

@MainActor
class MergeRequestsViewModel: ObservableObject {
    @Published var mergeRequests: [GitLabMergeRequest] = []
    /// `true` dès l'ouverture pour afficher le skeleton avant le premier chargement.
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    @Published var filterSheet: MergeRequestFilterSheet?
    @Published var state: MergeRequestState = .opened
    @Published var author: MergeRequestAuthorOption = .all
    
    /// Auteurs présents dans les merge requests chargées.
    var authorOptions: [MergeRequestAuthorOption] {
        let authors = Set(mergeRequests.map(\.author))
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { MergeRequestAuthorOption(id: $0.username, title: $0.name) }
        return [.all] + authors
    }
    
    var filteredMergeRequests: [GitLabMergeRequest] {
        guard author != .all else { return mergeRequests }
        return mergeRequests.filter { $0.author.username == author.id }
    }
    
    func load(project: GitLabProject, user: GitUser, showsSkeleton: Bool = true) async {
        if showsSkeleton {
            isLoading = true
            mergeRequests = []
        }
        errorMessage = nil
        author = .all
        defer { isLoading = false }
        
        do {
            mergeRequests = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.mergeRequestList(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    state: state
                )
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            errorMessage = error.gitLabMessage
        }
    }
}
