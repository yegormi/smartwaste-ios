//
//  Map.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var manager = LocationManager()
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        /// showing annotation on the map
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? LandmarkAnnotation else { return nil }
            return AnnotationView(annotation: annotation, reuseIdentifier: AnnotationView.ReuseID)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        MapViewRepresentable.Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.delegate = context.coordinator
        view.setRegion(manager.region, animated: false)
        view.mapType = .standard
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        for point in authVM.points {
            let annotation = LandmarkAnnotation(coordinate: point.coordinate)
            uiView.addAnnotation(annotation)
        }
    }
}

let testPoints: [Point] = [
    Point(id: "1", lat: 50.4501, lng: 30.5234, name: "Point 1", address: "Address 1"),
    Point(id: "2", lat: 50.451, lng: 30.524, name: "Point 2", address: "Address 2"),
    Point(id: "3", lat: 50.452, lng: 30.525, name: "Point 3", address: "Address 3"),
    Point(id: "4", lat: 50.453, lng: 30.526, name: "Point 4", address: "Address 4"),
    Point(id: "5", lat: 50.454, lng: 30.527, name: "Point 5", address: "Address 5"),
    Point(id: "6", lat: 50.455, lng: 30.528, name: "Point 6", address: "Address 6"),
    Point(id: "7", lat: 50.456, lng: 30.529, name: "Point 7", address: "Address 7"),
    Point(id: "8", lat: 50.457, lng: 30.530, name: "Point 8", address: "Address 8"),
    Point(id: "9", lat: 50.458, lng: 30.531, name: "Point 9", address: "Address 9"),
    Point(id: "10", lat: 50.459, lng: 30.532, name: "Point 10", address: "Address 10")
]

class LandmarkAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    init(
        coordinate: CLLocationCoordinate2D
    ) {
        self.coordinate = coordinate
        super.init()
    }
}


/// here posible to customize annotation view
let clusterID = "clustering"

class AnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "cultureAnnotation"
    
    /// setting the key for clustering annotations
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
    }
}

struct MapView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedPoint: Point?
    
    var body: some View {
        MapViewRepresentable()
            .onAppear {
                authVM.getPoints(token: authVM.response?.accessToken ?? "")
            }
            .popover(item: $selectedPoint) { point in
                VStack {
                    Text(point.name)
                        .font(.headline)
                    Text(point.address)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(AuthViewModel())
    }
}
