//
//  LoaderModifier.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct LoaderModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                update(isLoading)
            }
            .onChange(of: isLoading) { newValue in
                update(newValue)
            }
            .onDisappear {
                LoaderManager.shared.hide()
            }
    }
    
    private func update(_ isLoading: Bool) {
        if isLoading {
            LoaderManager.shared.show()
        } else {
            LoaderManager.shared.hide()
        }
    }
}

extension View {
    func loader(isLoading: Bool) -> some View {
        modifier(LoaderModifier(isLoading: isLoading))
    }
}
