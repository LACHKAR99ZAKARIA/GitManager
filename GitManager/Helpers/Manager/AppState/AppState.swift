//
//  AppState.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 11/5/2026.
//

import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    private let storageKey = "myUserListKey"
    private let loggedUserKey = "loggedUserKey"
    
    var users: [GitUser] {
        set {
            do {
                let encodedItems = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encodedItems, forKey: storageKey)
            } catch {
                print("Échec de l'encodage des utilisateurs: \(error)")
            }
        }
        get {
            if let data = UserDefaults.standard.data(forKey: storageKey) {
                do {
                    return try JSONDecoder().decode([GitUser].self, from: data)
                } catch {
                    print("Échec du décodage des utilisateurs: \(error)")
                    return []
                }
            } else {
                return []
            }
        }
    }
    
    var selectedUserID: UUID? {
        get {
            UserDefaults.standard.string(forKey: loggedUserKey).flatMap(UUID.init(uuidString:))
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue?.uuidString, forKey: loggedUserKey)
        }
    }
    
    /// Le compte sélectionné, ou le premier compte par défaut.
    var currentUser: GitUser? {
        let allUsers = users
        return allUsers.first { $0.id == selectedUserID } ?? allUsers.first
    }
    
    func selectUser(_ user: GitUser) {
        selectedUserID = user.id
    }
    
    /// À appeler uniquement une fois le token validé par GitLab.
    func addUser(_ user: GitUser) {
        objectWillChange.send()
        users.append(user)
        selectedUserID = user.id
    }
}
