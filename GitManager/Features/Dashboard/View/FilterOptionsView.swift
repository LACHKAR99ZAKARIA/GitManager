//
//  FilterOptionsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Sheet générique de choix d'une valeur parmi plusieurs (visibilité, tri…).
struct FilterOptionsView<Option: Identifiable & Hashable>: View {
    var title: String
    var options: [Option]
    var selection: Option
    var optionTitle: (Option) -> String
    var onSelect: (Option) -> Void
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.principal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(options) { option in
                            row(for: option)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func row(for option: Option) -> some View {
        Button {
            onSelect(option)
        } label: {
            HStack {
                Text(optionTitle(option))
                    .font(.body)
                    .foregroundStyle(Color.principal)
                
                Spacer(minLength: 0)
                
                if option == selection {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.principal)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(in: RoundedRectangle(cornerRadius: 12), interactive: true)
            // Sans ça, seul le texte réagit au tap : la zone vide de la ligne (Spacer) reste morte.
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FilterOptionsView(
        title: "Visibilité",
        options: ProjectVisibilityFilter.allCases,
        selection: .all,
        optionTitle: { $0.menuTitle },
        onSelect: { _ in }
    )
}
