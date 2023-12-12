//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct BucketMainView: View {
    let store: StoreOf<BucketMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("Bucket")
                    .font(.system(size: 36))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    ForEach(viewStore.bucket) { item in
                        BucketItemUI(
                            item: item,
                            onDecrement: {
                                viewStore.send(
                                    .updateItemCount(itemID: item.id, newCount: item.count - 1)
                                )
                            },
                            onIncrement: {
                                viewStore.send(
                                    .updateItemCount(itemID: item.id, newCount: item.count + 1)
                                )
                            }
                        )
                    }
                }
                .padding(.bottom, 10)
                
                VStack(spacing: 15) {
                    Button {
                        viewStore.send(.addButtonTapped)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.green, lineWidth: 2)
                            .frame(height: 60)
                            .overlay(
                                Text("Add item")
                                    .foregroundStyle(Color.green)
                                    .font(.system(size: 24))
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .scaleButton()
                    
                    Button {
                        viewStore.send(.showRecyclePointsTapped)
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                            .frame(height: 60)
                            .overlay(
                                Text("Show recycle points")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 20))
                            )
                    }
                    .scaleButton()
                }
            }
            .padding(20)
            .padding(.horizontal, 10)
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
            .sheet(
                store: self.store.scope(
                    state: \.$addItem,
                    action: \.addItem
                )
            ) { store in
                AddView(store: store)
                    .padding(30)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
