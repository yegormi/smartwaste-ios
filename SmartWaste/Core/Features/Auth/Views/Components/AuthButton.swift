//
//  AuthButton.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 06.11.2023.
//

import SwiftUI

struct AuthButton: View {
    let authType: AuthType
    let isLoading: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                Text(isLoading ? "" : authType.text.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1, anchor: .center)
                }
            }
            .disabled(isLoading)
        }
    }
}

struct AuthButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AuthButton(authType: .signIn, isLoading: true, color: .blue) {
                // Add your action here
            }
            .padding(20)

            AuthButton(authType: .signUp, isLoading: false, color: .red) {
                // Add your action here
            }
            .padding(20)
        }
    }
}
