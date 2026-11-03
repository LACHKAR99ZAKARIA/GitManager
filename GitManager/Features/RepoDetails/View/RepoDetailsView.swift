//
//  RepoDetailsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct RepoDetailsView: View {
    var project: GitLabProject
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RepoDetailsView(
            project: GitLabProject(
                id: 1,
                name: "Projet",
                nameWithNamespace: "groupe / Projet",
                description: nil,
                webURL: URL(string: "https://gitlab.com")!,
                avatarURL: nil,
                starCount: 0,
                forksCount: 0,
                visibility: nil,
                lastActivityAt: nil
            )
        )
    }
}
