//
//  MergeRequestsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct MergeRequestsView: View {
    var project: GitLabProject
    
    @StateObject private var appState = AppState.shared
    @StateObject private var viewModel = MergeRequestsViewModel()
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                filterBar
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .padding(.top, 12)
                        } else if !viewModel.isLoading && viewModel.filteredMergeRequests.isEmpty {
                            Text("Aucune merge request")
                                .font(.footnote)
                                .foregroundStyle(Color.neutral300)
                                .padding(.top, 12)
                        }
                        
                        if viewModel.isLoading {
                            ForEach(GitLabMergeRequest.placeholders) { mergeRequest in
                                row(for: mergeRequest)
                            }
                            .skeleton(isLoading: true)
                        } else {
                            ForEach(viewModel.filteredMergeRequests) { mergeRequest in
                                row(for: mergeRequest)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    guard let user = appState.currentUser else { return }
                    await viewModel.load(project: project, user: user, showsSkeleton: false)
                }
            }
        }
        .navigationTitle("Merge Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.state) {
            guard let user = appState.currentUser else {
                viewModel.isLoading = false
                return
            }
            await viewModel.load(project: project, user: user)
        }
        .sheet(item: $viewModel.filterSheet) { sheet in
            switch sheet {
            case .state:
                FilterOptionsView(
                    title: "État",
                    options: MergeRequestState.allCases,
                    selection: viewModel.state,
                    optionTitle: { $0.title },
                    onSelect: { state in
                        viewModel.state = state
                        viewModel.filterSheet = nil
                    }
                )
                .presentationDetents([.medium, .large])
            case .author:
                FilterOptionsView(
                    title: "Auteur",
                    options: viewModel.authorOptions,
                    selection: viewModel.author,
                    optionTitle: { $0.title },
                    onSelect: { author in
                        viewModel.author = author
                        viewModel.filterSheet = nil
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func row(for mergeRequest: GitLabMergeRequest) -> some View {
        VStack(spacing: 0) {
            MergeRequestRowView(mergeRequest: mergeRequest)
            
            Rectangle()
                .fill(Color.neutral200.opacity(0.6))
                .frame(height: 1)
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    viewModel.filterSheet = .state
                } label: {
                    FilterChip(title: viewModel.state.title, isActive: viewModel.state != .opened)
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.filterSheet = .author
                } label: {
                    FilterChip(
                        title: viewModel.author == .all ? "Auteur" : viewModel.author.title,
                        isActive: viewModel.author != .all
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 24)
            // Marge pour que l'ombre du glass ne soit pas coupée par le ScrollView.
            .padding(.vertical, 8)
        }
        .padding(.bottom, 4)
    }
}
