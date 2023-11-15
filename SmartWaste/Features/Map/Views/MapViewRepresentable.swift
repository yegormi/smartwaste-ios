//
//  MapViewRepresentable.swift
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
        view.showsUserLocation = true
        view.showsScale = true
        
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


class LandmarkAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
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
