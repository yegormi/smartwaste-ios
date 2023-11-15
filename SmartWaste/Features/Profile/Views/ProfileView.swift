//
//  ProfileView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                Text("yegormi")
                    .font(.headline)
                    .padding(.top, 8)
            }
            .padding(40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Achievements")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 8)
                
                AchievementCard(title: "Trash Collector", description: "Collected 50 pieces of trash", symbolName: "star.fill")
                
                AchievementCard(title: "Eco Warrior", description: "Sorted and recycled 30 items", symbolName: "leaf.fill")
                
                AchievementCard(title: "Green Thumb", description: "Planted 10 trees", symbolName: "leaf.arrow.circlepath")
            }
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
