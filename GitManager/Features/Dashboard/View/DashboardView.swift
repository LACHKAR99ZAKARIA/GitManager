//
//  DashboardView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 11/5/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            ZStack {
                Color.bg35
                    .ignoresSafeArea()
                
                if appState.users.isEmpty {
                    noUsersAvailableView
                } else {
                    usersAvailableView
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                route.view
            }
        }
        .task(id: appState.currentUser?.id) {
            guard let user = appState.currentUser else {
                viewModel.projects = []
                return
            }
            await viewModel.loadProjects(for: user)
        }
        .sheet(isPresented: $viewModel.showAccounts, onDismiss: {
            if viewModel.pendingAddUser {
                viewModel.pendingAddUser = false
                viewModel.presentAddUser()
            }
        }) {
            AccountsView(
                users: appState.users,
                selectedUserID: appState.currentUser?.id,
                onSelect: { user in
                    appState.selectUser(user)
                    viewModel.showAccounts = false
                },
                onAdd: {
                    viewModel.pendingAddUser = true
                    viewModel.showAccounts = false
                }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $viewModel.filterSheet) { sheet in
            switch sheet {
            case .visibility:
                FilterOptionsView(
                    title: "Visibilité",
                    options: ProjectVisibilityFilter.allCases,
                    selection: viewModel.visibilityFilter,
                    optionTitle: { $0.menuTitle },
                    onSelect: { filter in
                        viewModel.visibilityFilter = filter
                        viewModel.filterSheet = nil
                    }
                )
                .presentationDetents([.medium, .large])
            case .sort:
                FilterOptionsView(
                    title: "Trier par",
                    options: ProjectSort.allCases,
                    selection: viewModel.sort,
                    optionTitle: { $0.title },
                    onSelect: { sort in
                        viewModel.sort = sort
                        viewModel.filterSheet = nil
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $viewModel.showAddUser) {
            AddUserView(
                errorMessage: viewModel.addUserErrorMessage,
                isLoading: viewModel.isLoading,
                isUserValidated: viewModel.isUserValidated
            ) { url, token in
                Task {
                    guard let user = await viewModel.verifyUser(url: url, token: token) else { return }
                    appState.addUser(user)
                    viewModel.isUserValidated = true
                    // Laisse SwiftUI appliquer les textContentType avant de fermer la sheet.
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    viewModel.showAddUser = false
                }
            }
            .presentationDetents([.medium])
            .interactiveDismissDisabled(viewModel.isLoading)
        }
        .loader(isLoading: viewModel.isLoading)
    }

    var noUsersAvailableView: some View {
        EmptyStateView(
            imageResource: .noUsers,
            title: "Aucun compte",
            description: "Ajoutez votre compte GitLab avec un token d'accès pour afficher vos projets.",
            buttonTitle: "Ajouter un compte",
            action: {
                viewModel.presentAddUser()
            }
        )
    }
    
    var usersAvailableView: some View {
        VStack(spacing: 0) {
            if viewModel.isSearchVisible {
                SearchField(
                    placeholder: "Rechercher un dépôt",
                    text: $viewModel.searchText,
                    onClose: { viewModel.toggleSearch() }
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            } else {
                HStack {
                    Button {
                        viewModel.showAccounts = true
                    } label: {
                        AvatarView(url: appState.currentUser?.profileImage, size: 40)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .foregroundStyle(Color.principal)
                            .frame(width: 40, height: 40)
                            .glassBackground(in: Circle(), interactive: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            
            filterBar
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let errorMessage = viewModel.projectsErrorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else if viewModel.hasLoadedProjects && viewModel.filteredProjects.isEmpty {
                        Text(viewModel.projects.isEmpty ? "Aucun dépôt" : "Aucun dépôt ne correspond aux filtres")
                            .font(.footnote)
                            .foregroundStyle(Color.neutral300)
                    }
                    
                    if viewModel.isRepoLoading {
                        ForEach(GitLabProject.placeholders) { project in
                            ProjectRowView(project: project)
                        }
                        .skeleton(isLoading: true)
                    } else {
                        ForEach(viewModel.filteredProjects) { project in
                            ProjectRowView(project: project)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .refreshable {
                guard let user = appState.currentUser else { return }
                await viewModel.loadProjects(for: user, showsLoader: false)
            }
        }
    }
}

extension DashboardView {
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    viewModel.resetFilters()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease")
                        
                        if viewModel.activeFiltersCount > 0 {
                            Text("\(viewModel.activeFiltersCount)")
                                .font(.caption.bold())
                                .foregroundStyle(Color.bg10)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Color.principal, in: Circle())
                        }
                    }
                    .foregroundStyle(Color.principal)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassBackground(in: Capsule(), interactive: true)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.activeFiltersCount == 0)
                
                Button {
                    viewModel.filterSheet = .visibility
                } label: {
                    FilterChip(
                        title: viewModel.visibilityFilter.title,
                        isActive: viewModel.visibilityFilter != .all
                    )
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.filterSheet = .sort
                } label: {
                    FilterChip(title: "Tri : \(viewModel.sort.title)")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            // Marge pour que l'ombre du glass ne soit pas coupée par le ScrollView.
            .padding(.vertical, 8)
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    DashboardView()
}
