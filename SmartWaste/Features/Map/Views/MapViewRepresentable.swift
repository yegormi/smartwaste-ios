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
            if let cluster = annotation as? MKClusterAnnotation {
                return ClusterAnnotationView(
                    annotation: cluster,
                    reuseIdentifier: ClusterAnnotationView.ReuseID
                )
            } else {
                guard let annotaion = annotation as? LandmarkAnnotation else { return nil }
                let annotationView = ClusterAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: ClusterAnnotationView.ReuseID
                )
                annotationView.glyphText = "♻️"
                annotationView.markerTintColor = .white
                return annotationView
            }
        }
        
        func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
            let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
            cluster.title = ""
            cluster.subtitle = ""
            return cluster
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

let clusterID = "clustering"

class ClusterAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "clusterAnnotation"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultLow
        clusteringIdentifier = clusterID
        collisionMode = .circle
        markerTintColor = .systemGreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        canShowCallout = true
    }
}
