//
//  RepoInfoRow.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI

struct RepoInfoRow: View {
    var systemImage: String
    var tint: Color?
    var title: String
    var value: String?
    var showsChevron = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint == nil ? Color.principal : .white)
                .frame(width: 36, height: 36)
                .background(tint ?? Color.neutral100.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .font(.body)
                .foregroundStyle(Color.principal)
            
            Spacer(minLength: 0)
            
            if let value {
                Text(value)
                    .font(.body)
                    .foregroundStyle(Color.neutral300)
            }
            
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.neutral300)
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    RepoInfoRow(systemImage: "circle.dotted", tint: .green, title: "Issues", value: "0")
        .padding()
}
