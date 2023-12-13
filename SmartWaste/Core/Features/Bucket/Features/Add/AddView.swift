//
//  AddView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import SwiftUI
import ComposableArchitecture

struct AddView: View {
    let store: StoreOf<AddFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                Text(viewStore.title)
                    .font(.system(size: 30))
                    .padding(.bottom, 15)
                
                HStack(spacing: 15) {
                    Menu {
                        Picker("", selection: viewStore.binding(
                            get: \.selection,
                            send: { .selectionChanged($0 ?? viewStore.emptySelection) }
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
                    
                    Button(action: {
                        viewStore.send(.scanButtonTapped)
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 25))
                            .foregroundColor(Color.primary)
                    }
                }
                CounterView(
                    store: self.store.scope(
                        state: \.counter,
                        action: \.counter)
                )
                .padding(.top, 20)
                .padding(.bottom, (viewStore.countError != nil) ? 15 : 40)
                
                if let countError = viewStore.countError {
                    Text(countError)
                        .foregroundColor(.red)
                        .font(.system(size: 15))
                        .frame(height: 10)
                        .padding(.bottom, 15)
                }
                
                Button(action: {
                    viewStore.send(.addButtonTapped)
                }) {
                    Text("Add")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 10)
                
                Button(action: {
                    viewStore.send(.cancelButtonTapped)
                }) {
                    Text("Cancel")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .fullScreenCover(
                store: self.store.scope(
                    state: \.$camera,
                    action: \.camera
                )
            ) { store in
                CameraView(store: store)
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        let options: [BucketItemOption] = [
            BucketItemOption(id: 1, name: "Glass", categories: []),
            BucketItemOption(id: 2, name: "Paper", categories: []),
            BucketItemOption(id: 3, name: "Metal", categories: [])
        ]
        
        AddView(
            store: .init(
                initialState: .init(
                    counter: .init(min: 0, max: 10),
                    title: "Add item",
                    options: options,
                    selection: options.first
                )
            ) {
                AddFeature()
                    ._printChanges()
            }
        )
        .padding(30)
        .previewLayout(.sizeThatFits)
    }
}
