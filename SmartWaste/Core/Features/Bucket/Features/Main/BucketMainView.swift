//
//  BucketMainView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import AlertToast
import ComposableArchitecture
import SwiftUI

struct BucketMainView: View {
    let store: StoreOf<BucketMain>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("Bucket")
                    .font(.system(size: 36))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    ForEachStore(
                        self.store.scope(
                            state: \.bucketItems,
                            action: \.bucketItems
                        )
                    ) { store in
                        BucketItemView(store: store)
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
                viewStore.send(.viewDidAppear)
            }
            .sheet(
                store: self.store.scope(
                    state: \.$addItem,
                    action: \.addItem
                )
            ) { store in
                AddView(store: store)
                    .padding(30)
                    .presentationDetents([.height(370)])
                    .presentationDragIndicator(.visible)
            }
            .toast(isPresenting: viewStore.binding(
                get: \.isError,
                send: BucketMain.Action.errorToggled
            )) {
                AlertToast(displayMode: .alert, type: .error(.red), title: viewStore.errorToast)
            }
        }
    }
}
