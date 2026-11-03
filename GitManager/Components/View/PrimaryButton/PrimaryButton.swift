//
//  PrimaryButton.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.bg10)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.principal, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PrimaryButton(title: "Ajouter un compte") {}
        .padding()
}
