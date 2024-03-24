//
//  CounterView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 0) {
                Button {
                    viewStore.send(.decrement)
                } label: {
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
                .disabled(viewStore.minReached)
                .opacity(viewStore.minReached ? 0.3 : 1)
                .scaleButton()

                Text("\(viewStore.value)")
                    .font(.system(size: 28))
                    .frame(width: 60, height: 40)

                Button {
                    viewStore.send(.increment)
                } label: {
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
                .disabled(viewStore.maxReached)
                .opacity(viewStore.maxReached ? 0.3 : 1)
                .scaleButton()
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: Store(
                initialState: .init(min: 0, max: 10)
            ) {
                CounterFeature()
                    ._printChanges()
            }
        )
        .previewLayout(.sizeThatFits)
    }
}
