//
//  AnnotationDetailsVIew.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 09.12.2023.
//

import SwiftUI

struct AnnotationDetailsVIew: View {
    let annotation: AnnotationMark
    var onGoButtonTapped: () -> Void
    var onDumpBucketTapped: () -> Void
    let isAllowedToDump: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(annotation.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.primary)
            
            Text(annotation.address)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                ForEach(annotation.emoji, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 30))
                }
            }
            .padding(.bottom, 15)
            
            Button {
                onGoButtonTapped()
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
                onDumpBucketTapped()
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
            .disabled(!isAllowedToDump)
            .opacity(isAllowedToDump ? 1.0 : 0.5)
            .scaleButton()
        }
    }
}
