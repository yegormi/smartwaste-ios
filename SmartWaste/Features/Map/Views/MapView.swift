//
//  Map.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedPoint: Point?
    
    var body: some View {
        MapViewRepresentable()
            .onAppear {
                authVM.getPoints(token: authVM.response?.accessToken ?? "")
            }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AuthViewModel())
    }
}
