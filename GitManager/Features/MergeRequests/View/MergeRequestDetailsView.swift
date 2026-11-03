//
//  MergeRequestDetailsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct MergeRequestDetailsView: View {
    var project: GitLabProject
    var mergeRequest: GitLabMergeRequest
    
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = MergeRequestDetailsViewModel()
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    badges
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        authorAndDescription
                        changesSection
                        statusSection
                        conversationSection
                    }
                    .skeleton(isLoading: viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(mergeRequest.title)
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                        .lineLimit(1)
                    
                    Text(project.nameWithNamespace)
                        .font(.footnote)
                        .foregroundStyle(Color.neutral300)
                        .lineLimit(1)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if let url = viewModel.details?.webURL {
                    Menu {
                        ShareLink(item: url) {
                            Label("Partager", systemImage: "square.and.arrow.up")
                        }
                        
                        Link(destination: url) {
                            Label("Ouvrir dans le navigateur", systemImage: "safari")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                Button {
                    viewModel.commentErrorMessage = nil
                    viewModel.showComment = true
                } label: {
                    Label("Commenter", systemImage: "bubble.left")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .glassBackground(in: Capsule(), interactive: true)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .loader(isLoading: viewModel.isPosting)
        .sheet(isPresented: $viewModel.showComment) {
            CommentSheetView(
                errorMessage: viewModel.commentErrorMessage,
                isPosting: viewModel.isPosting
            ) { body in
                guard let user = appState.currentUser else { return }
                Task {
                    if await viewModel.postComment(body, project: project, mergeRequest: mergeRequest, user: user) {
                        viewModel.showComment = false
                    }
                }
            }
            .presentationDetents([.large])
            .interactiveDismissDisabled(viewModel.isPosting)
        }
        .task {
            guard let user = appState.currentUser else {
                viewModel.isLoading = false
                return
            }
            await viewModel.load(project: project, mergeRequest: mergeRequest, user: user)
        }
    }
    
    // MARK: - En-tête
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                AvatarView(url: project.avatarURL, size: 28)
                
                Text("\(project.nameWithNamespace) #\(mergeRequest.iid)")
                    .font(.subheadline)
                    .foregroundStyle(Color.neutral300)
                    .lineLimit(1)
            }
            
            Text(mergeRequest.title)
                .font(.title.bold())
                .foregroundStyle(Color.principal)
        }
    }
    
    private var badges: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: stateStyle.icon)
                    Text(stateStyle.title)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(stateStyle.color, in: Capsule())
                
                branchChip(mergeRequest.targetBranch)
                
                Image(systemName: "arrow.left")
                    .foregroundStyle(Color.neutral300)
                
                branchChip(mergeRequest.sourceBranch)
            }
        }
    }
    
    private func branchChip(_ name: String) -> some View {
        Text(name)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundStyle(Color.principal)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.neutral200.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.neutral200, lineWidth: 1))
    }
    
    private var stateStyle: (title: String, icon: String, color: Color) {
        switch mergeRequest.state {
        case "merged": return ("Fusionnée", "arrow.triangle.merge", .purple)
        case "closed": return ("Fermée", "xmark", .red)
        default: return ("Ouverte", "arrow.triangle.pull", .green)
        }
    }
    
    // MARK: - Auteur et description
    
    private var authorAndDescription: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                AvatarView(url: viewModel.details?.author?.avatarURL, size: 40)
                
                Text(authorLine)
                    .font(.headline)
                    .foregroundStyle(Color.principal)
            }
            
            if let description = viewModel.details?.description, !description.isEmpty {
                MarkdownText(markdown: description)
            } else if !viewModel.isLoading {
                Text("Aucune description")
                    .font(.footnote)
                    .foregroundStyle(Color.neutral300)
            }
        }
    }
    
    private var authorLine: String {
        let name = viewModel.details?.author?.username ?? mergeRequest.author.username
        guard let date = (viewModel.details?.createdAt).gitLabRelativeDate else { return name }
        return "\(name) · \(date)"
    }
    
    // MARK: - Modifications
    
    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Modifications")
            
            NavigationLink(value: Route.mergeRequestChanges(project, mergeRequest)) {
                row(icon: "doc.badge.plus", title: plural(viewModel.diffs.count, "fichier modifié", "fichiers modifiés")) {
                    HStack(spacing: 6) {
                        Text("+\(viewModel.additions)").foregroundStyle(.green)
                        Text("-\(viewModel.deletions)").foregroundStyle(.red)
                    }
                    .font(.body)
                }
            }
            .buttonStyle(.plain)
            
            divider
            
            NavigationLink(value: Route.mergeRequestCommits(project, mergeRequest)) {
                row(icon: "point.topleft.down.to.point.bottomright.curvepath", title: plural(viewModel.commits.count, "commit", "commits")) {
                    Text(viewModel.commits.first?.committedDate.gitLabRelativeDate ?? "")
                        .foregroundStyle(Color.neutral300)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Statut
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Statut")
            
            statusRow(icon: "person", color: Color.neutral300, title: reviewersText)
            divider
            
            let pipeline = pipelineStatus
            statusRow(icon: pipeline.icon, color: pipeline.color, title: pipeline.title)
            divider
            
            let merge = mergeStatus
            statusRow(icon: merge.icon, color: merge.color, title: merge.title, subtitle: merge.subtitle)
        }
    }
    
    private var reviewersText: String {
        guard let reviewers = viewModel.details?.reviewers, !reviewers.isEmpty else {
            return "Relecteurs · Aucun demandé"
        }
        return "Relecteurs · " + reviewers.map { "@\($0.username)" }.joined(separator: ", ")
    }
    
    private var pipelineStatus: (icon: String, color: Color, title: String) {
        switch viewModel.details?.headPipeline?.status {
        case "success": return ("checkmark.circle.fill", .green, "Pipeline réussi")
        case "failed": return ("xmark.circle.fill", .red, "Pipeline en échec")
        case "canceled": return ("minus.circle.fill", Color.neutral300, "Pipeline annulé")
        case "manual": return ("hand.raised.fill", .orange, "Action manuelle requise")
        case "running", "pending", "created", "preparing", "waiting_for_resource":
            return ("clock.fill", .orange, "Pipeline en cours")
        case .some(let other): return ("questionmark.circle.fill", Color.neutral300, "Pipeline : \(other)")
        case .none: return ("minus.circle", Color.neutral300, "Aucun pipeline")
        }
    }
    
    private var mergeStatus: (icon: String, color: Color, title: String, subtitle: String?) {
        switch mergeRequest.state {
        case "merged":
            return ("checkmark.circle.fill", .purple, "Fusionnée", nil)
        case "closed":
            return ("xmark.circle.fill", .red, "Fermée", nil)
        default:
            break
        }
        
        switch viewModel.details?.detailedMergeStatus {
        case "mergeable":
            return ("checkmark.circle.fill", .green, "Prête à être fusionnée",
                    "Seuls les membres avec un accès en écriture peuvent fusionner.")
        case "conflict":
            return ("exclamationmark.triangle.fill", .red, "Conflits à résoudre", nil)
        case "ci_must_pass", "ci_still_running":
            return ("clock.fill", .orange, "Le pipeline doit réussir", nil)
        case "not_approved":
            return ("exclamationmark.triangle.fill", .orange, "Approbation requise", nil)
        case "draft_status":
            return ("exclamationmark.triangle.fill", .orange, "Brouillon : pas prête à être fusionnée", nil)
        case "discussions_not_resolved":
            return ("exclamationmark.triangle.fill", .orange, "Discussions non résolues", nil)
        case "checking", "unchecked":
            return ("clock.fill", .orange, "Vérification en cours", nil)
        case .some(let other):
            return ("questionmark.circle.fill", Color.neutral300, other, nil)
        case .none:
            return ("questionmark.circle.fill", Color.neutral300, "Statut inconnu", nil)
        }
    }
    
    // MARK: - Conversation
    
    private var conversationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Conversation")
            
            if viewModel.notes.isEmpty && !viewModel.isLoading {
                Text("Aucun commentaire")
                    .font(.footnote)
                    .foregroundStyle(Color.neutral300)
                    .padding(.top, 8)
            }
            
            ForEach(viewModel.notes) { note in
                noteRow(note)
            }
        }
    }
    
    private func noteRow(_ note: GitLabNote) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if note.system {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                        .foregroundStyle(Color.neutral300)
                        .frame(width: 28)
                    
                    Text("@\(note.author.username) \(note.body)")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(Color.neutral300)
                }
                .padding(.vertical, 12)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        AvatarView(url: note.author.avatarURL, size: 28)
                        
                        Text(note.author.username)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.principal)
                        
                        if let date = note.createdAt.gitLabRelativeDate {
                            Text("· \(date)")
                                .font(.subheadline)
                                .foregroundStyle(Color.neutral300)
                        }
                    }
                    
                    MarkdownText(markdown: note.body)
                }
                .padding(.vertical, 12)
            }
            
            divider
        }
    }
    
    // MARK: - Composants
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(Color.principal)
            .padding(.bottom, 8)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.neutral200.opacity(0.6))
            .frame(height: 1)
    }
    
    private func row<Trailing: View>(icon: String, title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(Color.neutral300)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .foregroundStyle(Color.principal)
            
            Spacer(minLength: 8)
            
            trailing()
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.neutral300)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
    
    private func statusRow(icon: String, color: Color, title: String, subtitle: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.principal)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.neutral300)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
    }
    
    private func plural(_ count: Int, _ singular: String, _ plural: String) -> String {
        "\(count) \(count > 1 ? plural : singular)"
    }
}
