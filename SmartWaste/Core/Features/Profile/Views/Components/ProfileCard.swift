//
//  ProfileCard.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import SkeletonUI

struct ProfileCard: View {
    let user: User?

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .foregroundStyle(Color.gray)
                .font(.system(size: 80))
                .frame(width: 80, height: 80)
                .skeleton(with: user == nil,
                          size: CGSize(width: 80, height: 80),
                          shape: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(user?.username)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .skeleton(with: user == nil,
                              size: CGSize(width: 100, height: 20))

                Text(user?.email)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .skeleton(with: user == nil,
                              size: CGSize(width: 150, height: 15))
            }
        }
    }
}

struct ProfileCard_Previews: PreviewProvider {
    static var testItem: User = User(
        id: 1,
        email: "gleb.mokryy@gmail.com",
        username: "glebushkaa",
        score: 400,
        buckets: 2,
        createdAt: "2023-11-17T15:19:03.511Z"
    )

    static var previews: some View {
        ProfileCard(user: testItem)
            .previewLayout(.sizeThatFits)
    }
}
