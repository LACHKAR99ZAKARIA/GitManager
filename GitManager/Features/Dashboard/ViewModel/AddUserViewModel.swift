//
//  AddUserViewModel.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import Foundation
import Combine

class AddUserViewModel: ObservableObject {
    @Published var urlText = "https://gitlab.com"
    @Published var token = ""
    
    var url: URL? {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else { return nil }
        return url
    }
    
    var trimmedToken: String {
        token.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValid: Bool {
        url != nil && !trimmedToken.isEmpty
    }
}
