//
//  Error+GitLab.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation

extension Error {
    /// Message lisible pour une erreur d'appel à l'API GitLab.
    var gitLabMessage: String {
        let nsError = self as NSError
        
        if nsError.domain == "APIError" {
            switch nsError.code {
            case 401:
                return "Token invalide ou expiré."
            case 403:
                return "Accès refusé. Vérifiez les droits du token (scopes read_user et read_api)."
            case 404:
                return "Serveur GitLab introuvable à cette URL."
            case 409:
                return "Une merge request existe déjà pour ces branches."
            default:
                break
            }
        }
        
        if self is DecodingError {
            return "Réponse inattendue : cette URL ne semble pas être un serveur GitLab."
        }
        
        if nsError.domain == NSURLErrorDomain {
            return "Impossible de joindre le serveur. Vérifiez l'URL et votre connexion."
        }
        
        return APIError.custom(message: nsError.localizedDescription).message
    }
}
