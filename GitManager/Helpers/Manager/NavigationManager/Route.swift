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
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .repository(let project):
            RepoDetailsView(project: project)
        case .mergeRequests(let project):
            MergeRequestsView(project: project)
        }
    }
}
