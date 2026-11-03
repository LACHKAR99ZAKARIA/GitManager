//
//  AvatarView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 3/11/2026.
//

import SwiftUI
import Kingfisher

struct AvatarView: View {
    var url: URL?
    var size: CGFloat = 40
    
    var body: some View {
        Group {
            if let url {
                KFImage(url)
                    .placeholder { placeholder }
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.neutral200, lineWidth: 1))
    }
    
    private var placeholder: some View {
        ZStack {
            Color.bg25
            
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.45))
                .foregroundStyle(Color.neutral300)
        }
    }
}

#Preview {
    AvatarView(url: nil, size: 64)
}
