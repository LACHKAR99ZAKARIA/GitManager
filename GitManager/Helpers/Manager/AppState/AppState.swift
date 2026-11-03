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
}
