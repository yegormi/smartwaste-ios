//
//  AddItemView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.12.2023.
//
//

import SwiftUI

import SwiftUI

struct AddItemView: View {
    @Binding var optionSelected: String
    let items: [String]
    var onScanButtonTapped: () -> Void
    var onDecrement: () -> Void
    var onIncrement: () -> Void
    var onAddButtonTapped: () -> Void
    var onCancelButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add item")
                .font(.system(size: 24))
                .foregroundStyle(Color.primary)
                .padding(.vertical, 10)
            HStack(spacing: 15) {
                Picker("Select", selection: $optionSelected) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                    }
                }

                Button(action: onScanButtonTapped) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 25))
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(5)
                }
            }
            CounterView(value: 1, onDecrement: onDecrement, onIncrement: onIncrement)
                .padding(.top, 20)
                .padding(.bottom, 60)

            Button(action: onAddButtonTapped) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.green, lineWidth: 1)
                    .frame(height: 60)
                    .overlay(
                        Text("Add")
                            .foregroundStyle(Color.green)
                            .font(.system(size: 20))
                    )
            }
            .scaleButton()
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 10)

            Button(action: onCancelButtonTapped) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CancelButtonColor"))
                    .frame(height: 60)
                    .overlay(
                        Text("Cancel")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 20))
                    )
            }
            .scaleButton()
        }
    }
}
