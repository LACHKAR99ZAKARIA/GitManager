//
//  MergeRequestDetailsViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

@MainActor
class MergeRequestDetailsViewModel: ObservableObject {
    @Published var details: GitLabMergeRequestDetails?
    @Published var diffs: [GitLabDiff] = []
    @Published var commits: [GitLabCommit] = []
    @Published var notes: [GitLabNote] = []
    /// `true` dès l'ouverture pour afficher le skeleton avant le premier chargement.
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    @Published var showComment = false
    @Published var isPosting = false
    @Published var commentErrorMessage: String?
    
    var additions: Int { diffs.reduce(0) { $0 + $1.additions } }
    var deletions: Int { diffs.reduce(0) { $0 + $1.deletions } }
    
    func load(project: GitLabProject, mergeRequest: GitLabMergeRequest, user: GitUser) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let base = user.url
        let token = user.token
        async let diffList: [GitLabDiff]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.mergeRequestDiffs(baseURL: base, token: token, projectID: project.id, iid: mergeRequest.iid)
        )
        async let commitList: [GitLabCommit]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.mergeRequestCommits(baseURL: base, token: token, projectID: project.id, iid: mergeRequest.iid)
        )
        async let noteList: [GitLabNote]? = try? APIManager.shared.performRequest(
            for: GitLabEndpoint.mergeRequestNotes(baseURL: base, token: token, projectID: project.id, iid: mergeRequest.iid)
        )
        
        do {
            details = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.mergeRequestDetails(baseURL: base, token: token, projectID: project.id, iid: mergeRequest.iid)
            )
        } catch {
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            errorMessage = error.gitLabMessage
        }
        
        diffs = await diffList ?? []
        commits = await commitList ?? []
        notes = await noteList ?? []
    }
    
    /// Publie un commentaire (POST .../notes) puis recharge la conversation.
    func postComment(_ body: String, project: GitLabProject, mergeRequest: GitLabMergeRequest, user: GitUser) async -> Bool {
        isPosting = true
        commentErrorMessage = nil
        defer { isPosting = false }
        
        do {
            let _: GitLabNote = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.createNote(
                    baseURL: user.url,
                    token: user.token,
                    projectID: project.id,
                    iid: mergeRequest.iid,
                    body: body
                )
            )
            notes = (try? await APIManager.shared.performRequest(
                for: GitLabEndpoint.mergeRequestNotes(baseURL: user.url, token: user.token, projectID: project.id, iid: mergeRequest.iid)
            )) ?? notes
            return true
        } catch {
            let nsError = error as NSError
            if nsError.domain == "APIError" && [401, 403].contains(nsError.code) {
                commentErrorMessage = "Impossible de commenter : le token doit avoir le scope api."
            } else {
                commentErrorMessage = error.gitLabMessage
            }
            return false
        }
    }
}
