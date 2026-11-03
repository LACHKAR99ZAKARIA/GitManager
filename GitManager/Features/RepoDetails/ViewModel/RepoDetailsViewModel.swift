//
//  RepoDetailsViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

@MainActor
class RepoDetailsViewModel: ObservableObject {
    @Published var details: GitLabProjectDetails?
    @Published var mergeRequestsCount: Int?
    @Published var contributorsCount: Int?
    /// `true` dès l'ouverture pour afficher le skeleton avant même le premier chargement.
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    @Published var branches: [GitLabBranch] = []
    @Published var selectedBranch: String?
    @Published var showBranches = false
    
    @Published var isStarred = false
    @Published var starCount: Int?
    @Published var isTogglingStar = false
    
    /// Branche affichée : celle choisie, sinon la branche par défaut du projet.
    var currentBranch: String? {
        selectedBranch ?? details?.defaultBranch
    }
    
    func load(project: GitLabProject, user: GitUser) async {
        isLoading = true
        errorMessage = nil
        starCount = project.starCount
        defer { isLoading = false }
        
        async let mergeRequests: [GitLabListItem]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.mergeRequests(baseURL: user.url, token: user.token, projectID: project.id)
        )
        async let contributors: [GitLabListItem]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.contributors(baseURL: user.url, token: user.token, projectID: project.id)
        )
        async let branchList: [GitLabBranch]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.branches(baseURL: user.url, token: user.token, projectID: project.id)
        )
        async let starrers: [GitLabStarrer]? = loadStarrers(project: project, user: user)
        
        do {
            details = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.projectDetails(baseURL: user.url, token: user.token, projectID: project.id)
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            errorMessage = error.gitLabMessage
        }
        
        mergeRequestsCount = await mergeRequests?.count
        contributorsCount = await contributors?.count
        branches = await branchList ?? []
        
        if let username = user.username, let starrers = await starrers {
            isStarred = starrers.contains { $0.user.username.caseInsensitiveCompare(username) == .orderedSame }
        }
    }
    
    /// Met ou retire l'étoile. Le changement est appliqué tout de suite puis annulé si GitLab refuse.
    func toggleStar(project: GitLabProject, user: GitUser) async {
        guard !isTogglingStar else { return }
        isTogglingStar = true
        errorMessage = nil
        defer { isTogglingStar = false }
        
        let wasStarred = isStarred
        let previousCount = starCount ?? project.starCount
        isStarred = !wasStarred
        starCount = max(0, previousCount + (wasStarred ? -1 : 1))
        
        let endpoint: GitLabEndpoint = wasStarred
            ? .unstar(baseURL: user.url, token: user.token, projectID: project.id)
            : .star(baseURL: user.url, token: user.token, projectID: project.id)
        
        do {
            let result: GitLabStarResult = try await APIManager.shared.performRequest(for: endpoint)
            starCount = result.starCount
        } catch {
            let nsError = error as NSError
            if nsError.domain == "APIError" && nsError.code == 304 {
                // Déjà dans l'état demandé côté GitLab : on garde l'état, mais pas le compteur modifié.
                starCount = previousCount
                return
            }
            
            isStarred = wasStarred
            starCount = previousCount
            if nsError.domain == "APIError" && [401, 403].contains(nsError.code) {
                errorMessage = "Impossible de modifier l'étoile : le token doit avoir le scope api."
            } else {
                errorMessage = error.gitLabMessage
            }
        }
    }
    
    private func loadStarrers(project: GitLabProject, user: GitUser) async -> [GitLabStarrer]? {
        guard let username = user.username else { return nil }
        return try? await APIManager.shared.performRequest(
            for: GitLabEndpoint.starrers(baseURL: user.url, token: user.token, projectID: project.id, search: username)
        )
    }
}
