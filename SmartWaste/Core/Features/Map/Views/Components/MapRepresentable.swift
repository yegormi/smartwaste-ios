//
//  MapRepresentable.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import SwiftUI
import MapKit

struct MapRepresentable: UIViewRepresentable {
    @StateObject var locationManager = LocationManager.shared
    let mapPoints: [MapPoint]
    let onAnnotationTapped: (AnnotationMark) -> Void
    
    init(mapPoints: [MapPoint], onAnnotationTapped: @escaping (AnnotationMark) -> Void) {
        self.mapPoints = mapPoints
        self.onAnnotationTapped = onAnnotationTapped
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapRepresentable
        
        init(_ parent: MapRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let cluster = annotation as? MKClusterAnnotation else {
                return createAnnotationView(for: annotation)
            }
            return createClusterAnnotationView(for: cluster)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? AnnotationMark {
                print("Marker tapped! Name: \(annotation.name), Address: \(annotation.address)")
                parent.onAnnotationTapped(annotation)
            }
        }
        
        func mapView(
            _ mapView: MKMapView,
            clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]
        ) -> MKClusterAnnotation {
            let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
            cluster.title = ""
            cluster.subtitle = ""
            return cluster
        }
        
        
        func createAnnotationView(for annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is AnnotationMark else { return nil }
            
            let annotationView = ClusterAnnotationView(
                annotation: annotation,
                reuseIdentifier: ClusterAnnotationView.ReuseID
            )
            annotationView.glyphText = "♻️"
            annotationView.markerTintColor = .white
            return annotationView
        }
        
        func createClusterAnnotationView(for cluster: MKClusterAnnotation) -> MKAnnotationView {
            return ClusterAnnotationView(
                annotation: cluster,
                reuseIdentifier: ClusterAnnotationView.ReuseID
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(locationManager.region, animated: false)
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotations = mapPoints.map { createAnnotation(from: $0) }
        uiView.addAnnotations(annotations)
    }
    
    private func createAnnotation(from point: MapPoint) -> AnnotationMark {
        return AnnotationMark(
            coordinate: point.coordinate,
            name: point.name,
            address: point.address,
            emojiList: point.categories.map { $0.emoji }
        )
    }
}

class AnnotationMark: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let emojiList: [String]
    
    init(coordinate: CLLocationCoordinate2D, name: String, address: String, emojiList: [String]) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.emojiList = emojiList
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
