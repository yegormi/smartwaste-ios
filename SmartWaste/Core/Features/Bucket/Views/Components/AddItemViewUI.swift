//
//  AddItemViewUI.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 07.12.2023.
//

import SwiftUI

struct AddItemViewUI: View {
    var title: String
    var options: [BucketItemOption]
    @Binding var selection: BucketItemOption?
    var onScanButtonTapped: () -> Void
    
    var onAddButtonTapped: (BucketItem) -> Void
    var onCancelButtonTapped: () -> Void
    
    let hasNotch = UIDevice.current.hasNotch
    
    @State private var count = 0 {
        didSet {
            self.countError = nil
        }
    }
    
    @State private var countError: String? = nil
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 30))
                .padding(.bottom, 15)
            
            HStack(spacing: 15) {
                Menu {
                    Picker("", selection: $selection) {
                        ForEach(options) { option in
                            Text(option.name).tag(option as BucketItemOption?)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection?.name)
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
                    self.onScanButtonTapped()
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 25))
                        .foregroundColor(Color.primary)
                }
            }
            CounterView(
                value: self.count,
                limit: BucketItem.limit,
                onDecrement: { self.count -= 1 },
                onIncrement: { self.count += 1  }
            )
            .padding(.top, 20)
            .padding(.bottom, (countError != nil) ? 15 : 40)
            
            if let countError = self.countError {
                Text(countError)
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                    .frame(height: 10)
                    .padding(.bottom, 15)
            }
            
            Button(action: {
                let item = self.createBucketItem()
                if item.count <= 0 {
                    self.countError = "You must add 1 or more items"
                }
                self.onAddButtonTapped(item)
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
                self.onCancelButtonTapped()
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
        .onAppear {
            self.setInitialOption()
        }
    }
    
    private func setInitialOption() {
        self.selection = self.options.first
    }
    
    private func createBucketItem() -> BucketItem {
        guard let selectedOption = selection else {
            fatalError("Selection should not be nil.")
        }
        
        return BucketItem(
            id: selectedOption.id,
            name: selectedOption.name,
            count: count, 
            categories: selectedOption.categories
        )
    }
}

struct AddItemViewUI_Previews: PreviewProvider {
    static var previews: some View {
        let options: [BucketItemOption] = [
            BucketItemOption(id: 1, name: "Option 1", categories: []),
            BucketItemOption(id: 2, name: "Option 2", categories: []),
            BucketItemOption(id: 3, name: "Option 3", categories: [])
        ]
        @State var selection: BucketItemOption? = (options.first ?? BucketItemOption(id: 1, name: "Material", categories: []))

        AddItemViewUI(
            title: "Add item",
            options: options,
            selection: $selection,
            onScanButtonTapped: {},
            onAddButtonTapped: { _ in },
            onCancelButtonTapped: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
