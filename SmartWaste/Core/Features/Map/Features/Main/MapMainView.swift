//
//  MapMainView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//

import SwiftUI
import ComposableArchitecture
import AlertToast

struct MapMainView: View {
    let store: StoreOf<MapMain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            MapRepresentable(mapPoints: viewStore.points) { annotation in
                viewStore.send(.onAnnotationTapped(annotation))
            }
            .onAppear {
                if !viewStore.viewDidAppear {
                    viewStore.send(.viewDidAppear)
                }
            }
            .sheet(
                store: self.store.scope(
                    state: \.$details,
                    action: \.details
                )
            ) { store in
                AnnotationView(store: store)
                    .padding(30)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
            .toast(isPresenting: viewStore.binding(
                get: \.isSuccessToastPresented,
                send: MapMain.Action.successToastPresented)
            ) {
                AlertToast(displayMode: .alert, type: .complete(.green), title: "Bucket has been successfully dumped!")
            }
        }
    }
}
