//
//  BucketItemOptionView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct BucketItemOptionView: View {
    let item: BucketItemOption
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 60)
            .overlay(
                HStack {
                    Text(item.name)
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Button(action: onDecrement) {
                        RoundedRectangle(cornerRadius: 10)
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
                    
                    Text("\(0)")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 10)
                    
                    Button(action: onIncrement) {
                        RoundedRectangle(cornerRadius: 10)
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
                    .padding(20)
            )
    }
}

struct BucketItemOptionView_Previews: PreviewProvider {
    static var testItem: BucketItemOption = BucketItemOption(id: 1, name: "Plastic bottle", categories: [])
    
    static var previews: some View {
        BucketItemOptionView(
            item: testItem,
            onDecrement: {},
            onIncrement: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
