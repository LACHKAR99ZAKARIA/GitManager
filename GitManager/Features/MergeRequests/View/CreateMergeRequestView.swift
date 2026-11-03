//
//  CreateMergeRequestView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct CreateMergeRequestView: View {
    var project: GitLabProject
    var errorMessage: String?
    var isCreating: Bool
    var onSubmit: (_ source: String, _ target: String, _ title: String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = CreateMergeRequestViewModel()
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choisir les branches")
                            .font(.title3.bold())
                            .foregroundStyle(Color.neutral300)
                        
                        branchesCard
                        
                        Text("Choisissez deux branches pour voir ce qui a changé ou pour créer une merge request.")
                            .font(.footnote)
                            .foregroundStyle(Color.neutral300)
                        
                        comparisonCard
                        
                        if viewModel.compareBranch != nil {
                            titleField
                        }
                        
                        if let message = errorMessage ?? viewModel.loadErrorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
                PrimaryButton(title: "Créer la merge request") {
                    guard let source = viewModel.compareBranch?.name,
                          let target = viewModel.baseBranch?.name else { return }
                    onSubmit(source, target, viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                .disabled(!viewModel.canSubmit || isCreating)
                .opacity(viewModel.canSubmit ? 1 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .task {
            guard let user = appState.currentUser else { return }
            await viewModel.loadBranches(project: project, user: user)
        }
        .sheet(item: $viewModel.branchSheet) { sheet in
            BranchPickerView(
                title: sheet == .base ? "Branche de base" : "Branche à comparer",
                branches: viewModel.branches,
                selectedName: (sheet == .base ? viewModel.baseBranch : viewModel.compareBranch)?.name
            ) { branch in
                guard let user = appState.currentUser else { return }
                viewModel.select(branch, for: sheet, project: project, user: user)
            }
            .presentationDetents([.large])
        }
    }
    
    // MARK: - Sections
    
    private var header: some View {
        ZStack {
            VStack(spacing: 2) {
                Text("Nouvelle merge request")
                    .font(.headline)
                    .foregroundStyle(Color.principal)
                
                Text(project.nameWithNamespace)
                    .font(.footnote)
                    .foregroundStyle(Color.neutral300)
                    .lineLimit(1)
            }
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                        .frame(width: 44, height: 44)
                        .glassBackground(in: Circle(), interactive: true)
                }
                .buttonStyle(.plain)
                .disabled(isCreating)
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    private var branchesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("base :")
                .font(.body)
                .foregroundStyle(Color.neutral300)
            
            branchButton(
                name: viewModel.baseBranch?.name,
                placeholder: "Choisir une branche",
                sheet: .base
            )
            
            Rectangle()
                .fill(Color.neutral200.opacity(0.6))
                .frame(height: 1)
                .padding(.vertical, 4)
            
            Text("compare :")
                .font(.body)
                .foregroundStyle(Color.neutral300)
            
            branchButton(
                name: viewModel.compareBranch?.name,
                placeholder: "Choisir une branche",
                sheet: .compare
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(in: RoundedRectangle(cornerRadius: 20))
    }
    
    private func branchButton(name: String?, placeholder: String, sheet: MergeRequestBranchSheet) -> some View {
        Button {
            viewModel.branchSheet = sheet
        } label: {
            HStack(spacing: 6) {
                if let name {
                    Text(name)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.principal)
                } else {
                    Text(placeholder)
                        .font(.body)
                        .foregroundStyle(Color.principal)
                }
                
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.neutral300)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassBackground(in: RoundedRectangle(cornerRadius: 10), interactive: true)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.branches.isEmpty)
    }
    
    private var comparisonCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.triangle.pull")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.green)
                .frame(width: 56, height: 56)
                .background(Color.green.opacity(0.15), in: Circle())
            
            if viewModel.isComparing {
                ProgressView()
            } else {
                Text(comparisonText)
                    .font(.headline)
                    .foregroundStyle(Color.principal)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassBackground(in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Titre")
                .font(.subheadline)
                .foregroundStyle(Color.neutral300)
            
            TextField("Titre de la merge request", text: $viewModel.title)
                .foregroundStyle(Color.principal)
                .padding(14)
                .glassBackground(in: RoundedRectangle(cornerRadius: 12))
                .onChange(of: viewModel.title) { _ in
                    viewModel.userEditedTitle()
                }
        }
    }
    
    private var comparisonText: String {
        guard viewModel.compareBranch != nil else {
            return "Choisissez une branche à comparer"
        }
        guard let comparison = viewModel.comparison else {
            return viewModel.baseBranch == viewModel.compareBranch
                ? "Choisissez deux branches différentes"
                : "Comparaison indisponible"
        }
        guard viewModel.hasChanges else {
            return "Aucune différence entre ces branches"
        }
        return "\(comparison.commitsCount) commit\(comparison.commitsCount > 1 ? "s" : "") · \(comparison.filesCount) fichier\(comparison.filesCount > 1 ? "s" : "") modifié\(comparison.filesCount > 1 ? "s" : "")"
    }
}
