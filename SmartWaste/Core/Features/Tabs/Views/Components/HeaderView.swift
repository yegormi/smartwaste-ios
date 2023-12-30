//
//  HeaderView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import SwiftUI

struct HeaderView: View {
    let text: String
    let hasNotch: Bool = UIDevice.current.hasNotch

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 20))
                .bold()
                .padding(.top, hasNotch ? 0 : 10)
                .padding(.leading, 20)
            Spacer()
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView("♻️ SmartWaste")
            .previewLayout(.sizeThatFits)
    }
}
