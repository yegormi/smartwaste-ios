//
//  QuestView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct QuestView: View {
    let label: String
    let value: Int
    let total: Int

    init(_ label: String, value: Int, total: Int) {
        self.label = label
        self.value = value
        self.total = total
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(value == total ? Color("QuestGreen") : Color("QuestYellow"))
            .frame(height: 50)
            .overlay(
                HStack {
                    Text(label)
                    Spacer()
                    Text("\(value)/\(total)")
                }
                .padding()
                .foregroundStyle(Color.white)
                .font(.system(size: 16, weight: .bold))
            )
    }
}

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            QuestView("Quest 1", value: 2, total: 5)
                .previewLayout(.sizeThatFits)
                .padding()

            QuestView("Quest 2", value: 0, total: 3)
                .previewLayout(.sizeThatFits)
                .padding()

            QuestView("Quest 3", value: 5, total: 5)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
