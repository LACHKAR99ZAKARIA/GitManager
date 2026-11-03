//
//  MarkdownText.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

/// Rendu simple d'un texte Markdown GitLab : titres, listes à puces, gras, liens, code en ligne.
struct MarkdownText: View {
    var markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(markdown.components(separatedBy: "\n").enumerated()), id: \.offset) { _, line in
                if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    row(for: line)
                }
            }
        }
        .tint(Color.principal)
    }
    
    @ViewBuilder
    private func row(for line: String) -> some View {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("#") {
            let title = trimmed.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
            Text(inline(title))
                .font(.title3.bold())
                .foregroundStyle(Color.principal)
        } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                Text(inline(String(trimmed.dropFirst(2))))
            }
            .font(.body)
            .foregroundStyle(Color.principal)
        } else {
            Text(inline(trimmed))
                .font(.body)
                .foregroundStyle(Color.principal)
        }
    }
    
    private func inline(_ text: String) -> AttributedString {
        (try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(text)
    }
}
