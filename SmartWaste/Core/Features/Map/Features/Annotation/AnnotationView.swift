//
//  AnnotationView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 12.12.2023.
//
//

import SwiftUI
import ComposableArchitecture

struct AnnotationView: View {
    let store: StoreOf<AnnotationFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 10) {
                Text(viewStore.annotation.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(viewStore.annotation.address)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 10) {
                    ForEach(viewStore.annotation.emojiList, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 30))
                    }
                }
                .padding(.bottom, 15)
                
                Button {
                    viewStore.send(.goButtonTapped)
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.green, lineWidth: 2)
                        .frame(height: 60)
                        .overlay(
                            Text("Go")
                                .foregroundStyle(Color.green)
                                .font(.system(size: 24))
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .scaleButton()
                .padding(.bottom, 10)
                
                Button {
                    viewStore.send(.dumpBucketTapped)
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green)
                        .frame(height: 60)
                        .overlay(
                            Text("Dump bucket")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 20))
                        )
                }
                .disabled(!viewStore.isAllowedToDump)
                .opacity(viewStore.isAllowedToDump ? 1.0 : 0.5)
                .scaleButton()
            }
            .confirmationDialog(
                store: self.store.scope(
                    state: \.$confirmationDialog,
                    action: \.confirmationDialog
                )
            )
        }
    }
}
