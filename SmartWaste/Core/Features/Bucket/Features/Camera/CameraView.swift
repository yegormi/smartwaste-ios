//
//  CameraView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 13.12.2023.
//
//

import ComposableArchitecture
import SwiftUI

struct CameraView: View {
    let store: StoreOf<CameraFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            CameraRepresentable { image in
                viewStore.send(.usePhotoTapped(with: image))
            }
            .ignoresSafeArea(.all)
        }
    }
}
