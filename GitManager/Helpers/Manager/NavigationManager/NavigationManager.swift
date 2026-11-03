//
//  NavigationManager.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var path = NavigationPath()
    
    private init() {}
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}
