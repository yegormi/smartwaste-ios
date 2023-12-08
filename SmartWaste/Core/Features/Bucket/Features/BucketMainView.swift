//
//  MapMain.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI
import ComposableArchitecture
import AlertToast

struct BucketMainView: View {
    let store: StoreOf<BucketMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text("Bucket")
                    .font(.system(size: 30))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    ForEach(viewStore.bucket) { item in
                        BucketItemView(
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
                        viewStore.send(.sheetToggled(true))
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
            .padding([.horizontal, .bottom], 30)
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isSheetPresented,
                send: BucketMain.Action.sheetToggled
            )) {
                AddItemViewUI(
                    title: "Add item",
                    options: viewStore.bucketOptions,
                    selection: viewStore.binding(
                        get: \.optionSelected,
                        send: { .selectionChanged($0 ?? BucketItemOption(id: 1, name: "Material", categories: [])) }
                    ),
                    onScanButtonTapped: { viewStore.send(.onScanButtonTapped) },
                    onAddButtonTapped: { item in
                        if item.count <= 0 {
                            return
                        }
                        print("Add button tapped! item: \(item.name) and count: \(item.count)")
                        viewStore.send(.setBucket(with: item))
                        viewStore.send(.sheetToggled(false))
                    },
                    onCancelButtonTapped: { viewStore.send(.sheetToggled(false)) }
                )
                .padding(30)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                
                .toast(isPresenting: viewStore.binding(
                    get: \.isErrorToastPresented,
                    send: BucketMain.Action.errorToastToggled
                )) {
                    AlertToast(displayMode: .alert, type: .error(.red), title: "No suitable item was detected")
                }
                .toast(isPresenting: viewStore.binding(
                    get: \.isLoadingToastPresented,
                    send: BucketMain.Action.loadingToastToggled
                )) {
                    AlertToast(type: .loading, title: "Scanning image")
                }
                
                .fullScreenCover(isPresented: viewStore.binding(
                    get: \.isCameraPresented,
                    send: BucketMain.Action.cameraPresented
                )) {
                    CameraView(
                        capturedImage: viewStore.binding(
                            get: \.capturedImage,
                            send: { .imageCaptured($0 ?? UIImage.strokedCheckmark) }
                        ),
                        onImageSelected: {
                            viewStore.send(.usePhotoTapped)
                        }
                    )
                }
            }
        }
    }
}

