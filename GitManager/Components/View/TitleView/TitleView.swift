//
//  TitleView.swift
//  GitManager
//
//  Created by Zakaria Lachkar on 17/7/2026.
//

import SwiftUI

struct TitleView: View {
    var icon: ImageResource
    var title: String
    var description: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(icon)
                .resizable()
//                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.title2)
            
            if let description {
                Text(description)
            }
        }
    }
}

//#Preview {
//    TitleView()
//}
