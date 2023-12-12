//
//  CounterUI.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//

import SwiftUI

struct CounterUI: View {
    var value: Int
    let limit: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onDecrement) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
                    .foregroundStyle(Color.white.opacity(0.1))
                    .overlay(
                        Text("-")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 28))
                    )
            }
            .frame(width: 40, height: 40)
            .disabled(value <= 0)
            .opacity(value <= 0 ? 0.3 : 1)
            .scaleButton()
            
            Text("\(value)")
                .font(.system(size: 28))
                .frame(width: 60, height: 40)
            
            Button(action: onIncrement) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
                    .foregroundStyle(Color.white.opacity(0.1))
                    .overlay(
                        Text("+")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 28))
                    )
            }
            .disabled(value >= limit)
            .opacity(value >= limit ? 0.3 : 1)
            .frame(width: 40, height: 40)
            .scaleButton()
        }
    }
}

struct CounterUI_Previews: PreviewProvider {
    static var previews: some View {
        @State var value: Int = 0
        CounterUI(
            value: value,
            limit: 10,
            onDecrement: { value -= 1 },
            onIncrement: { value += 1 }
        )
        .previewLayout(.sizeThatFits)
    }
}