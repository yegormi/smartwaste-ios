//
//  AchievementCard.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import SwiftUI

struct AchievementCard: View {
    var title: String
    var description: String
    var symbolName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: symbolName)
                    .foregroundColor(.yellow)
                
                Text(title)
                    .font(.headline)
                    .bold()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color("FieldColor")))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .padding(.bottom, 8)
    }
}
