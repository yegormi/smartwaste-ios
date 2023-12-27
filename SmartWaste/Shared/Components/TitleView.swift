//
//  TitleView.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.11.2023.
//

import SwiftUI

struct TitleView: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 20))
            .bold()
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView("♻️ SmartWaste")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
