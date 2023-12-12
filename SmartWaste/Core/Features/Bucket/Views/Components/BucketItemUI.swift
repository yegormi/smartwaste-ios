//
//  BucketItemUI.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//

import SwiftUI

struct BucketItemUI: View {
    var item: BucketItem
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 60)
            .overlay(
                HStack {
                    Text(item.name)
                    Spacer()
                    CounterUI(
                        value: item.count,
                        limit: BucketItem.limit,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement
                    )
                }
                    .padding(20)
            )
    }
}

struct BucketItemUI_Previews: PreviewProvider {
    static var testItem: BucketItem = BucketItem(id: 1, name: "Plastic bottle", count: 0, categories: [])
    
    static var previews: some View {
        BucketItemUI(
            item: testItem,
            onDecrement: {},
            onIncrement: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
