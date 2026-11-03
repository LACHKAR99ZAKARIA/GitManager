//
//  MergeRequestFilter.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

/// Sheet de filtre actuellement affichée sur l'écran des merge requests.
enum MergeRequestFilterSheet: Identifiable {
    case state
    case author
    
    var id: Self { self }
}

/// État demandé à GitLab (`state=`) : le filtre est appliqué côté serveur.
enum MergeRequestState: String, CaseIterable, Identifiable {
    case opened
    case merged
    case closed
    case all
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .opened: return "Ouvertes"
        case .merged: return "Fusionnées"
        case .closed: return "Fermées"
        case .all: return "Toutes"
        }
    }
}

/// Auteur proposé dans le filtre (appliqué sur les merge requests déjà chargées).
struct MergeRequestAuthorOption: Identifiable, Hashable {
    let id: String
    let title: String
    
    static let all = MergeRequestAuthorOption(id: "", title: "Tous")
}
