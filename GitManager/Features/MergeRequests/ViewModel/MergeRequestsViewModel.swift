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
    
    @Published var searchText = ""
    @Published var isSearchVisible = false
    
    @Published var showCreate = false
    @Published var isCreating = false
    @Published var createErrorMessage: String?
    
    /// Auteurs présents dans les merge requests chargées.
    var authorOptions: [MergeRequestAuthorOption] {
        let authors = Set(mergeRequests.map(\.author))
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { MergeRequestAuthorOption(id: $0.username, title: $0.name) }
        return [.all] + authors
    }
    
    var filteredMergeRequests: [GitLabMergeRequest] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return mergeRequests.filter { mergeRequest in
            let matchesAuthor = author == .all || mergeRequest.author.username == author.id
            let matchesSearch = query.isEmpty
                || mergeRequest.title.localizedCaseInsensitiveContains(query)
                || "#\(mergeRequest.iid)".contains(query)
                || mergeRequest.author.name.localizedCaseInsensitiveContains(query)
                || mergeRequest.author.username.localizedCaseInsensitiveContains(query)
                || mergeRequest.sourceBranch.localizedCaseInsensitiveContains(query)
            return matchesAuthor && matchesSearch
        }
    }
    
    func presentCreate() {
        createErrorMessage = nil
        showCreate = true
    }
    
    func toggleSearch() {
        isSearchVisible.toggle()
        if !isSearchVisible {
            searchText = ""
        }
    }
    
    /// Crée la merge request (POST /projects/:id/merge_requests). Retourne `true` en cas de succès.
    func createMergeRequest(project: GitLabProject, user: GitUser, source: String, target: String, title: String) async -> Bool {
        isCreating = true
        createErrorMessage = nil
        defer { isCreating = false }
        
        do {
            let _: GitLabMergeRequest = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.createMergeRequest(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    source: source,
                    target: target,
                    title: title
                )
            )
            return true
        } catch {
            let nsError = error as NSError
            if nsError.domain == "APIError" && [401, 403].contains(nsError.code) {
                createErrorMessage = "Impossible de créer la merge request : le token doit avoir le scope api."
            } else {
                createErrorMessage = error.gitLabMessage
            }
            return false
        }
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
