//
//  StatBox.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct StatBox: View {
    let label: String
    let value: Int

    init(_ label: String, value: Int) {
        self.label = label
        self.value = value
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(Color.white.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                VStack {
                    Text("\(value)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text(label)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white)
                }
            )
    }
}

struct StatBox_Previews: PreviewProvider {
    static var previews: some View {
        StatBox("Level", value: 228)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
