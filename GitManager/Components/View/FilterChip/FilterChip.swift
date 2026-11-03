//
//  FilterChip.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Pastille de filtre, à utiliser comme label d'un `Button` qui ouvre une sheet.
struct FilterChip: View {
    var title: String
    var isActive = false
    var showsChevron = true
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
            
            if showsChevron {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
        }
        .foregroundStyle(isActive ? Color.bg10 : Color.principal)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassBackground(in: Capsule(), tint: isActive ? Color.principal : nil, interactive: true)
    }
}

#Preview {
    HStack {
        FilterChip(title: "Visibilité")
        FilterChip(title: "Public", isActive: true)
    }
}
