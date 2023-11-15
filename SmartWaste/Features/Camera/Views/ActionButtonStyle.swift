//
//  ButtonStyle.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding(15)
            .background(RoundedRectangle(cornerRadius: 15).fill(color))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
