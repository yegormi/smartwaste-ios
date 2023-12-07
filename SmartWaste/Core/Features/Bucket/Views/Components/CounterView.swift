//
//  CounterView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct CounterView: View {
    var value: Int
    let limit: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onDecrement) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 1)
                    .foregroundStyle(Color.clear)
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
                .font(.system(size: 32))
                .frame(width: 60, height: 40)
            
            Button(action: onIncrement) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 1)
                    .foregroundStyle(Color.clear)
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

struct CounterView_Previews: PreviewProvider {
    static var value: Int = 0
    static var previews: some View {
        CounterView(
            value: value,
            limit: 10,
            onDecrement: { value -= 1 },
            onIncrement: { value += 1 }
        )
        .previewLayout(.sizeThatFits)
    }
}
