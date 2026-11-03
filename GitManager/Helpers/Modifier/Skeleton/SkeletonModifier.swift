//
//  SkeletonModifier.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Transforme n'importe quelle vue en skeleton : le contenu est remplacé par des blocs
/// `placeholder` qui pulsent, et les interactions sont désactivées pendant le chargement.
struct SkeletonModifier: ViewModifier {
    var isLoading: Bool
    
    @State private var isDimmed = false
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .opacity(isLoading && isDimmed ? 0.45 : 1)
            .allowsHitTesting(!isLoading)
            .animation(
                isLoading ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                value: isDimmed
            )
            .onAppear {
                isDimmed = isLoading
            }
            .onChange(of: isLoading) { newValue in
                isDimmed = newValue
            }
    }
}

extension View {
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}
