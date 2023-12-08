//
//  MapViewRepresentable.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @StateObject var manager = LocationManager()
    let points: [MapPoint]
    let onAnnotationTapped: (AnnotationMark) -> Void
    
    init(points: [MapPoint], onAnnotationTapped: @escaping (AnnotationMark) -> Void) {
        self.points = points
        self.onAnnotationTapped = onAnnotationTapped
    }
    
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
                guard annotation is AnnotationMark else { return nil }
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
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? AnnotationMark {
                print("Marker tapped! Name: \(annotation.name), Address: \(annotation.address)")
                parent.onAnnotationTapped(annotation)
            }
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
        
        for point in points {
            let annotation = AnnotationMark(
                coordinate: point.coordinate,
                name: point.name,
                address: point.address,
                emoji: point.categories.map { $0.emoji }
            )
            uiView.addAnnotation(annotation)
        }
    }
}

class AnnotationMark: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let emoji: [String]

    init(coordinate: CLLocationCoordinate2D, name: String, address: String, emoji: [String]) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.emoji = emoji
        super.init()
    }
}


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

let clusterID = "clustering"




class Callout: UIView {
    private let titleLabel = UILabel(frame: .zero)
    private let addressLabel = UILabel(frame: .zero)
    private let annotation: AnnotationMark
    
    init(annotation: AnnotationMark) {
        self.annotation = annotation
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setupTitle()
        setupAddress()
    }
    
    private func setupTitle() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = annotation.name
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupAddress() {
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .gray
        addressLabel.text = annotation.address
        addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
