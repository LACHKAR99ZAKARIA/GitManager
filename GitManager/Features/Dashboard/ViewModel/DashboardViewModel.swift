//
//  DashboardViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 12/5/2026.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var showAddUser = false
    @Published var showAccounts = false
    /// Le bouton « Ajouter un nouveau compte » ferme d'abord la sheet des comptes, puis ouvre celle d'ajout.
    var pendingAddUser = false
    
    @Published var isLoading = false
    /// Passe à `true` seulement quand GitLab a validé le token : c'est alors que les champs
    /// deviennent des identifiants pour iOS, ce qui permet la popup « Enregistrer le mot de passe ».
    @Published var isUserValidated = false
    @Published var addUserErrorMessage: String?
    
    @Published var projects: [GitLabProject] = []
    @Published var isLoadingProjects = false
    @Published var hasLoadedProjects = false
    @Published var projectsErrorMessage: String?
    
    func presentAddUser() {
        addUserErrorMessage = nil
        isUserValidated = false
        showAddUser = true
    }
    
    /// Vérifie le token auprès de GitLab (GET /api/v4/user) et retourne l'utilisateur prêt à être enregistré.
    func verifyUser(url: URL, token: String) async -> GitUser? {
        isLoading = true
        addUserErrorMessage = nil
        defer { isLoading = false }
        
        do {
            let profile: GitLabUser = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.currentUser(baseURL: url, token: token)
            )
            return GitUser(
                url: url,
                token: token,
                profileImage: profile.avatarURL,
                username: profile.username,
                name: profile.name
            )
        } catch {
            addUserErrorMessage = message(for: error)
            return nil
        }
    }
    
    /// Charge les dépôts du compte (GET /api/v4/projects). Au changement de compte la liste est vidée.
    func loadProjects(for user: GitUser, showsLoader: Bool = true) async {
        if showsLoader {
            projects = []
            hasLoadedProjects = false
            isLoadingProjects = true
        }
        projectsErrorMessage = nil
        defer { isLoadingProjects = false }
        
        do {
            let result: [GitLabProject] = try await APIManager.shared.performRequest(
                for: GitLabEndpoint.projects(baseURL: user.url, token: user.token)
            )
            projects = result
            hasLoadedProjects = true
        } catch {
            // Une tâche annulée (changement de compte) n'est pas une erreur à afficher.
            if (error as? URLError)?.code == .cancelled || error is CancellationError { return }
            projectsErrorMessage = message(for: error)
            hasLoadedProjects = true
        }
    }
    
    private func message(for error: Error) -> String {
        let nsError = error as NSError
        
        if nsError.domain == "APIError" {
            switch nsError.code {
            case 401:
                return "Token invalide ou expiré."
            case 403:
                return "Accès refusé. Vérifiez les droits du token (scopes read_user et read_api)."
            case 404:
                return "Serveur GitLab introuvable à cette URL."
            default:
                break
            }
        }
        
        if error is DecodingError {
            return "Réponse inattendue : cette URL ne semble pas être un serveur GitLab."
        }
        
        if nsError.domain == NSURLErrorDomain {
            return "Impossible de joindre le serveur. Vérifiez l'URL et votre connexion."
        }
        
        return APIError.custom(message: nsError.localizedDescription).message
    }
}
