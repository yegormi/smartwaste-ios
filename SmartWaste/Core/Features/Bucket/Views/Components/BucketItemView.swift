//
//  BucketItemView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 05.12.2023.
//

import SwiftUI

struct BucketItemView: View {
    let item: BucketItem
    let onDecrease: ()
    let onIncrease: ()

    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color("BucketItemColor"))
            .frame(height: 60)
            .overlay(
                HStack {
                    Text(item.name)
                        .foregroundStyle(Color.white)

                    Spacer()
                    
                    Button {
                        onDecrease
                    } label: {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.red)
                            .overlay (
                                Text("-")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 28))
                            )
                    }
                    .frame(width: 40, height: 40)
                    
                    Text("\(0)")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)

                    Button {
                        onIncrease
                    } label: {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.green)
                            .overlay (
                                Text("+")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 28))
                            )
                    }
                    .frame(width: 40, height: 40)
                }.padding(20)
            )
    }
}

struct BucketItemView_Previews: PreviewProvider {
    static var testItem: BucketItem = BucketItem(id: 1, name: "Plastic bottle", categories: [])
    
    static var previews: some View {
        BucketItemView(
            item: testItem,
            onDecrease: (),
            onIncrease: ()
        )
        .previewLayout(.sizeThatFits)
    }
}
