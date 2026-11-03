//
//  RepoDetailsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct RepoDetailsView: View {
    var project: GitLabProject
    
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = RepoDetailsViewModel()
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    actions
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        infoSection
                        branchSection
                        codeSection
                    }
                    .skeleton(isLoading: viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showBranches) {
            BranchPickerView(
                title: "Choisir une branche",
                branches: viewModel.branches,
                selectedName: viewModel.currentBranch
            ) { branch in
                viewModel.selectedBranch = branch.name
                viewModel.showBranches = false
            }
            .presentationDetents([.large])
        }
        .task {
            guard let user = appState.currentUser else {
                viewModel.isLoading = false
                return
            }
            await viewModel.load(project: project, user: user)
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                AvatarView(url: project.avatarURL, size: 28)
                
                Text(namespace)
                    .font(.subheadline)
                    .foregroundStyle(Color.neutral300)
            }
            
            Text(project.name)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.principal)
            
            if let description = project.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.principal)
            }
            
            HStack(spacing: 24) {
                Label("\(viewModel.starCount ?? project.starCount) étoiles", systemImage: "star.fill")
                Label("\(project.forksCount) forks", systemImage: "arrow.triangle.branch")
            }
            .font(.subheadline)
            .foregroundStyle(Color.neutral300)
        }
    }
    
    // TODO: brancher l'action Fork sur l'API GitLab.
    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                guard let user = appState.currentUser else { return }
                Task { await viewModel.toggleStar(project: project, user: user) }
            } label: {
                Label {
                    Text(viewModel.isStarred ? "Étoilé" : "Étoile")
                } icon: {
                    Image(systemName: viewModel.isStarred ? "star.fill" : "star")
                        .foregroundStyle(viewModel.isStarred ? Color.yellow : Color.principal)
                }
                .font(.headline)
                .foregroundStyle(Color.principal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .glassBackground(in: Capsule(), interactive: true)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading || viewModel.isTogglingStar)
            
            Button {} label: {
                Image(systemName: "arrow.triangle.branch")
                    .font(.headline)
                    .foregroundStyle(Color.principal)
                    .padding(14)
                    .glassBackground(in: Circle(), interactive: true)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 0) {
            RepoInfoRow(
                systemImage: "smallcircle.filled.circle",
                tint: .green,
                title: "Issues",
                value: placeholder(viewModel.details?.openIssuesCount.map(String.init))
            )
            divider
            NavigationLink(value: Route.mergeRequests(project)) {
                RepoInfoRow(
                    systemImage: "arrow.triangle.pull",
                    tint: .blue,
                    title: "Merge Requests",
                    value: placeholder(countText(viewModel.mergeRequestsCount))
                )
            }
            .buttonStyle(.plain)
            divider
            RepoInfoRow(
                systemImage: "play.circle",
                tint: .yellow,
                title: "Pipelines"
            )
            divider
            RepoInfoRow(
                systemImage: "person.2",
                tint: .orange,
                title: "Contributeurs",
                value: placeholder(countText(viewModel.contributorsCount))
            )
            divider
            RepoInfoRow(
                systemImage: "scalemass",
                tint: .red,
                title: "Licence",
                value: viewModel.details?.license?.name ?? "Aucune",
                showsChevron: false
            )
        }
    }
    
    private var branchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.branch")
                .foregroundStyle(Color.neutral300)
            
            Text(viewModel.currentBranch ?? "—")
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Color.neutral300)
            
            Spacer(minLength: 0)
            
            Button {
                viewModel.showBranches = true
            } label: {
                Text("Changer de branche")
                    .font(.body)
                    .foregroundStyle(Color.principal)
            }
        }
    }
    
    private var codeSection: some View {
        VStack(spacing: 0) {
            RepoInfoRow(systemImage: "chevron.left.forwardslash.chevron.right", title: "Code")
            divider
            RepoInfoRow(
                systemImage: "point.topleft.down.to.point.bottomright.curvepath",
                title: "Commits",
                value: placeholder(viewModel.details?.statistics.map { String($0.commitCount) })
            )
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.neutral200.opacity(0.6))
            .frame(height: 1)
            .padding(.leading, 52)
    }
    
    // MARK: - Helpers
    
    private var namespace: String {
        // « groupe / sous-groupe / projet » → « groupe / sous-groupe »
        let parts = project.nameWithNamespace.components(separatedBy: " / ")
        return parts.dropLast().joined(separator: " / ")
    }
    
    /// Pendant le chargement, une valeur factice donne sa forme au skeleton.
    private func placeholder(_ value: String?) -> String? {
        viewModel.isLoading ? "00" : value
    }
    
    /// L'API est limitée à 100 résultats par page.
    private func countText(_ count: Int?) -> String? {
        guard let count else { return nil }
        return count >= 100 ? "100+" : String(count)
    }
}

#Preview {
    NavigationStack {
        RepoDetailsView(
            project: GitLabProject(
                id: 1,
                name: "Projet",
                nameWithNamespace: "groupe / Projet",
                description: "Description du projet",
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
