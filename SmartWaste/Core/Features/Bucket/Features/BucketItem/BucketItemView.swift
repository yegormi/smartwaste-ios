//
//  BucketItemView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import SwiftUI
import ComposableArchitecture

struct BucketItemView: View {
    let store: StoreOf<BucketItemFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 60)
                .overlay(
                    HStack {
                        Text(viewStore.item.name)
                        Spacer()
                        CounterView(
                            store: self.store.scope(
                                state: \.counter,
                                action: \.counter
                            )
                        )
                    }.padding(20)
                )
            
        }
    }
}

struct BucketItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = BucketItem(id: 1, name: "Plastic bottle", count: 5, categories: [])
        
        BucketItemView(
            store: Store(
                initialState: .init(
                    item: item,
                    counter: CounterFeature.State(min: 0, max: 10, value: item.count)
                )
            ) {
                BucketItemFeature()
            }
        )
        .padding(20)
        .previewLayout(.sizeThatFits)
    }
}
