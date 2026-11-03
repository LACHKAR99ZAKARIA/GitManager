//
//  View+Glass.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

extension View {
    /// Fond « liquid glass » sur iOS 26+, contour (ou fond teinté) sur les versions antérieures.
    @ViewBuilder
    func glassBackground<S: Shape>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        if #available(iOS 26, *) {
            var glass = Glass.regular
            if let tint {
                glass = glass.tint(tint)
            }
            if interactive {
                glass = glass.interactive()
            }
            return self.glassEffect(glass, in: shape)
        } else {
            return self
                .background(tint ?? .clear, in: shape)
                .overlay(shape.stroke(Color.neutral200, lineWidth: tint == nil ? 1 : 0))
        }
    }
}
