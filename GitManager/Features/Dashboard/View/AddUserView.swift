//
//  AddUserView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct AddUserView: View {
    @StateObject private var viewModel = AddUserViewModel()
    
    var errorMessage: String?
    var isLoading: Bool
    var isUserValidated: Bool
    var onSubmit: (URL, String) -> Void
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Ajouter un compte")
                    .font(.title2.bold())
                    .foregroundStyle(Color.principal)
            
                field(title: "URL") {
                    TextField("https://gitlab.com", text: $viewModel.urlText)
                        .keyboardType(.URL)
                        .textContentType(isUserValidated ? .username : .URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            
                field(title: "Token d'accès") {
                    SecureField("glpat-xxxxxxxxxxxxxxxxxxxx", text: $viewModel.token)
                        .textContentType(isUserValidated ? .password : .oneTimeCode)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            
                Spacer(minLength: 0)
            
                PrimaryButton(title: "Ajouter") {
                    guard let url = viewModel.url else { return }
                    onSubmit(url, viewModel.trimmedToken)
                }
                .disabled(!viewModel.isValid || isLoading)
                .opacity(viewModel.isValid ? 1 : 0.5)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.neutral300)
            
            content()
                .foregroundStyle(Color.principal)
                .padding(14)
                .background(Color.bg25, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    AddUserView(errorMessage: nil, isLoading: false, isUserValidated: false) { _, _ in }
}
