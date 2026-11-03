//
//  Route.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 12/5/2026.
//

import SwiftUI

enum Route {
    case repository
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .repository:
            EmptyView()
        }
    }
}
