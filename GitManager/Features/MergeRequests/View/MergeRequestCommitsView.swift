//
//  MergeRequestCommitsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct MergeRequestCommitsView: View {
    var project: GitLabProject
    var mergeRequest: GitLabMergeRequest
    
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = MergeRequestCommitsViewModel()
    
    private static let placeholders: [GitLabCommit] = (1...5).map {
        GitLabCommit(id: "\($0)", title: "Titre du commit", authorName: "Auteur", committerName: "Auteur", committedDate: nil)
    }
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.top, 12)
                    }
                    
                    if viewModel.isLoading {
                        ForEach(Self.placeholders) { commit in
                            row(for: commit)
                        }
                        .skeleton(isLoading: true)
                    } else {
                        ForEach(viewModel.commits) { commit in
                            row(for: commit)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Commits")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let user = appState.currentUser else {
                viewModel.isLoading = false
                return
            }
            await viewModel.load(project: project, mergeRequest: mergeRequest, user: user)
        }
    }
    
    private func row(for commit: GitLabCommit) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(commit.title)
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                        .multilineTextAlignment(.leading)
                    
                    Spacer(minLength: 8)
                    
                    if let date = commit.committedDate.gitLabRelativeDate {
                        Text(date)
                            .font(.subheadline)
                            .foregroundStyle(Color.neutral300)
                    }
                }
                
                Text(authorship(for: commit))
                    .font(.subheadline)
                    .foregroundStyle(Color.neutral300)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Rectangle()
                .fill(Color.neutral200.opacity(0.6))
                .frame(height: 1)
        }
    }
    
    private func authorship(for commit: GitLabCommit) -> String {
        guard let committer = commit.committerName, committer != commit.authorName else {
            return "\(commit.authorName) a créé le commit"
        }
        return "\(commit.authorName) a écrit et \(committer) a validé"
    }
}
