//
//  MergeRequestChangesView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct MergeRequestChangesView: View {
    var project: GitLabProject
    var mergeRequest: GitLabMergeRequest
    
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = MergeRequestChangesViewModel()
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(24)
                    } else if viewModel.isLoading {
                        ForEach(0..<6, id: \.self) { _ in
                            Text("Ligne de code factice pour le skeleton")
                                .font(.system(.footnote, design: .monospaced))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 6)
                        }
                        .skeleton(isLoading: true)
                    } else if viewModel.diffs.isEmpty {
                        Text("Aucun fichier modifié")
                            .font(.footnote)
                            .foregroundStyle(Color.neutral300)
                            .padding(24)
                    }
                    
                    ForEach(viewModel.diffs) { file in
                        fileSection(file)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Fichiers modifiés")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                    
                    HStack(spacing: 6) {
                        Text("+\(viewModel.additions)")
                            .foregroundStyle(.green)
                        Text("-\(viewModel.deletions)")
                            .foregroundStyle(.red)
                    }
                    .font(.footnote.weight(.semibold))
                }
            }
        }
        .task {
            guard let user = appState.currentUser else {
                viewModel.isLoading = false
                return
            }
            await viewModel.load(project: project, mergeRequest: mergeRequest, user: user)
        }
    }
    
    private func fileSection(_ file: GitLabDiff) -> some View {
        let isCollapsed = viewModel.collapsedFiles.contains(file.id)
        
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                viewModel.toggle(file)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.neutral300)
                    
                    Text(file.newPath)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(Color.principal)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer(minLength: 8)
                    
                    Text("+\(file.additions)")
                        .foregroundStyle(.green)
                    Text("-\(file.deletions)")
                        .foregroundStyle(.red)
                }
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.neutral200.opacity(0.25))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if !isCollapsed {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(file.lines) { line in
                            lineRow(line)
                        }
                    }
                }
            }
        }
    }
    
    private func lineRow(_ line: DiffLine) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(line.newNumber.map(String.init) ?? line.oldNumber.map(String.init) ?? "")
                .frame(width: 44, alignment: .trailing)
                .foregroundStyle(Color.neutral300)
                .padding(.trailing, 8)
            
            Text(prefix(for: line) + line.text)
                .foregroundStyle(line.kind == .hunk ? Color.neutral300 : Color.principal)
                .fixedSize(horizontal: true, vertical: false)
            
            Spacer(minLength: 24)
        }
        .font(.system(.footnote, design: .monospaced))
        .padding(.vertical, 4)
        .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
        .background(background(for: line))
    }
    
    private func prefix(for line: DiffLine) -> String {
        switch line.kind {
        case .added: return "+"
        case .removed: return "-"
        default: return ""
        }
    }
    
    private func background(for line: DiffLine) -> Color {
        switch line.kind {
        case .added: return Color.green.opacity(0.25)
        case .removed: return Color.red.opacity(0.25)
        case .hunk: return Color.neutral200.opacity(0.35)
        case .context: return .clear
        }
    }
}
