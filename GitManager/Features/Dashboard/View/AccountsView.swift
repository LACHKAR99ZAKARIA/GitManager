//
//  AccountsView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct AccountsView: View {
    var users: [GitUser]
    var selectedUserID: UUID?
    var onSelect: (GitUser) -> Void
    var onAdd: () -> Void
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Comptes")
                    .font(.title2.bold())
                    .foregroundStyle(Color.principal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(users) { user in
                            row(for: user)
                        }
                    }
                }
                
                PrimaryButton(title: "Ajouter un nouveau compte", action: onAdd)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func row(for user: GitUser) -> some View {
        Button {
            onSelect(user)
        } label: {
            HStack(spacing: 12) {
                AvatarView(url: user.profileImage, size: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name ?? user.username ?? "Compte")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                    
                    Text(subtitle(for: user))
                        .font(.footnote)
                        .foregroundStyle(Color.neutral300)
                }
                
                Spacer(minLength: 0)
                
                if user.id == selectedUserID {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.principal)
                }
            }
            .padding(12)
            .background(Color.bg25, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func subtitle(for user: GitUser) -> String {
        [user.username.map { "@\($0)" }, user.url.host]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

#Preview {
    AccountsView(users: [], selectedUserID: nil, onSelect: { _ in }, onAdd: {})
}
