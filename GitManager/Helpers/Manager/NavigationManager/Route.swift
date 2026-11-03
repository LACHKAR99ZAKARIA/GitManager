//
//  Route.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 12/5/2026.
//

import SwiftUI

enum Route: Hashable {
    case repository(GitLabProject)
    case mergeRequests(GitLabProject)
    case mergeRequestDetails(GitLabProject, GitLabMergeRequest)
    case mergeRequestChanges(GitLabProject, GitLabMergeRequest)
    case mergeRequestCommits(GitLabProject, GitLabMergeRequest)
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .repository(let project):
            RepoDetailsView(project: project)
        case .mergeRequests(let project):
            MergeRequestsView(project: project)
        case .mergeRequestDetails(let project, let mergeRequest):
            MergeRequestDetailsView(project: project, mergeRequest: mergeRequest)
        case .mergeRequestChanges(let project, let mergeRequest):
            MergeRequestChangesView(project: project, mergeRequest: mergeRequest)
        case .mergeRequestCommits(let project, let mergeRequest):
            MergeRequestCommitsView(project: project, mergeRequest: mergeRequest)
        }
    }
}
