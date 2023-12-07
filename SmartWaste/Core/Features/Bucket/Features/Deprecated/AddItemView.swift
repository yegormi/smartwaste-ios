//
//  AddItemView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//
//

import SwiftUI
import ComposableArchitecture

struct AddItemView: View {
    let store: StoreOf<AddItemFeature>
    
    let hasNotch = UIDevice.current.hasNotch
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Text("Add item")
                    .font(.system(size: 30))
                    .padding(.bottom, 15)
                
                HStack(spacing: 15) {
                    Menu {
                        Picker("", selection: viewStore.binding(
                            get: \.selection,
                            send: { .pickerChanged($0 ?? BucketItemOption(id: 1, name: "Material", categories: [])) }
                        )) {
                            ForEach(viewStore.options) { option in
                                Text(option.name).tag(option as BucketItemOption?)
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewStore.selection?.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.horizontal, 5)
                        }
                        .tint(Color.primary)
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        viewStore.send(.onScanButtonTapped)
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 25))
                            .foregroundStyle(Color.black.opacity(0.8))
                    }
                }
                CounterView(
                    value: viewStore.count,
                    limit: BucketItem.limit,
                    onDecrement: { viewStore.send(.onDecrement) },
                    onIncrement: { viewStore.send(.onIncrement) }
                )
                .padding(.top, 20)
                .padding(.bottom, 60)
                
                Button {
                    viewStore.send(.addButtonTapped)
                } label: {
                    Text("Add")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)
                
                Button {
                    viewStore.send(.cancelButtonTapped)
                } label: {
                    Text("Cancel")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)
            }
            .padding(.bottom, hasNotch ? 0 : 20)
            .padding(.horizontal, 30)
            .onAppear {
                viewStore.send(.viewDidAppear)
            }
        }
    }
}
