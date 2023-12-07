//
//  CounterView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct CounterView: View {
    let value: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onDecrement) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.gray, lineWidth: 1)
                    .foregroundStyle(Color.clear)
                    .overlay(
                        Text("-")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 28))
                    )
            }
            .frame(width: 40, height: 40)
            .scaleButton()
            
            Text("\(value)")
                .font(.system(size: 32))
                .padding(.horizontal, 20)
            
            Button(action: onIncrement) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.gray, lineWidth: 1)
                    .foregroundStyle(Color.clear)
                    .overlay(
                        Text("+")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 28))
                    )
            }
            .frame(width: 40, height: 40)
            .scaleButton()
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        @State var value: Int = 0
        CounterView(value: value, onDecrement: { value -= 1 }, onIncrement: { value += 1 })
    }
}
