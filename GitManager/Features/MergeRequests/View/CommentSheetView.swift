//
//  CommentSheetView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct CommentSheetView: View {
    var errorMessage: String?
    var isPosting: Bool
    var onSubmit: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack {
            Color.bg35
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Text("Commenter")
                        .font(.headline)
                        .foregroundStyle(Color.principal)
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundStyle(Color.principal)
                                .frame(width: 44, height: 44)
                                .glassBackground(in: Circle(), interactive: true)
                        }
                        .buttonStyle(.plain)
                        .disabled(isPosting)
                        
                        Spacer()
                    }
                }
                
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(Color.principal)
                    .focused($isFocused)
                    .padding(12)
                    .frame(maxHeight: .infinity)
                    .glassBackground(in: RoundedRectangle(cornerRadius: 16))
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                
                PrimaryButton(title: "Envoyer") {
                    onSubmit(trimmedText)
                }
                .disabled(trimmedText.isEmpty || isPosting)
                .opacity(trimmedText.isEmpty ? 0.5 : 1)
            }
            .padding(24)
        }
        .onAppear {
            isFocused = true
        }
    }
}
