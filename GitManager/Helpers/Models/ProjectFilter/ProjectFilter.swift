//
//  ProjectFilter.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

/// Sheet de filtre actuellement affichée.
enum ProjectFilterSheet: Identifiable {
    case visibility
    case sort
    
    var id: Self { self }
}

enum ProjectVisibilityFilter: String, CaseIterable, Identifiable {
    case all
    case `public`
    case `internal`
    case `private`
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .all: return "Visibilité"
        case .public: return "Public"
        case .internal: return "Interne"
        case .private: return "Privé"
        }
    }
    
    /// Libellé dans le menu (la valeur par défaut y est « Toutes »).
    var menuTitle: String {
        self == .all ? "Toutes" : title
    }
}

enum ProjectSort: String, CaseIterable, Identifiable {
    case recentActivity
    case name
    case stars
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .recentActivity: return "Activité récente"
        case .name: return "Nom"
        case .stars: return "Étoiles"
        }
    }
}
