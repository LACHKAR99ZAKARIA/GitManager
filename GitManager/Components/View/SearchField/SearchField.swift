//
//  SearchField.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Barre de recherche en glass qui prend la place de l'en-tête : la croix à droite ferme la recherche.
/// Le clavier s'ouvre dès qu'elle apparaît.
struct SearchField: View {
    var placeholder: String
    @Binding var text: String
    var onClose: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.neutral300)
            
            TextField(placeholder, text: $text)
                .foregroundStyle(Color.principal)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
            
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(Color.principal)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassBackground(in: Capsule())
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    SearchField(placeholder: "Rechercher", text: .constant(""), onClose: {})
        .padding()
}
