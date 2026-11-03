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
        .loader(isLoading: viewModel.isLoading || viewModel.isLoadingProjects)
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
            HStack {
                Button {
                    viewModel.showAccounts = true
                } label: {
                    AvatarView(url: appState.currentUser?.profileImage, size: 40)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let errorMessage = viewModel.projectsErrorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else if viewModel.hasLoadedProjects && viewModel.projects.isEmpty {
                        Text("Aucun dépôt")
                            .font(.footnote)
                            .foregroundStyle(Color.neutral300)
                    }
                    
                    ForEach(viewModel.projects) { project in
                        ProjectRowView(project: project)
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

#Preview {
    DashboardView()
}
