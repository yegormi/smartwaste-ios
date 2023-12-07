//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture
import PartialSheet

struct BucketMainView: View {
    let store: StoreOf<BucketMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("Bucket")
                    .font(.system(size: 32, weight: .semibold))
                Spacer()
                Picker("Select", selection: viewStore.binding(
                    get: \.itemSelected,
                    send: BucketMain.Action.selectionChanged
                )) {
                    ForEach(viewStore.types, id: \.self) { option in
                        Text(option)
                    }
                }
                VStack(spacing: 15) {
                    Button {
                        viewStore.send(.sheetToggled)
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
            .padding(30)
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
            .partialSheet(isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: BucketMain.Action.sheetToggled
            )) {
                AddItemView(
                    optionSelected: viewStore.binding(
                        get: \.itemSelected,
                        send: BucketMain.Action.selectionChanged
                    ),
                    items: viewStore.types,
                    onScanButtonTapped: { viewStore.send(.onScanButtonTapped) },
                    onDecrement: {},
                    onIncrement: {},
                    onAddButtonTapped: {},
                    onCancelButtonTapped: { viewStore.send(.sheetToggled) }
                )
                .padding(.horizontal, 30)
            }
        }
    }
}

