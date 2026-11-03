//
//  EmptyStateView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct EmptyStateView: View {
    var imageResource: ImageResource
    var title: String
    var description: String
    var buttonTitle: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(imageResource)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(Color.neutral300)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.principal)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(Color.neutral300)
            }
            .multilineTextAlignment(.center)
            
            PrimaryButton(title: buttonTitle, action: action)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        imageResource: .noUsers,
        title: "Aucun compte",
        description: "Ajoutez votre compte GitLab avec un token d'accès pour afficher vos projets.",
        buttonTitle: "Ajouter un compte",
        action: {}
    )
}
