//
//  Route.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 12/5/2026.
//

import SwiftUI

enum Route: Hashable {
    case repository(GitLabProject)
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .repository(let project):
            RepoDetailsView(project: project)
        }
    }
}
