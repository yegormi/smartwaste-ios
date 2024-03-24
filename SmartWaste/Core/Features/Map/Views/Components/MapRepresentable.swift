//
//  MapRepresentable.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 15.11.2023.
//

import MapKit
import SwiftUI

struct MapRepresentable: UIViewRepresentable {
    let mapPoints: [MapPoint]
    let onSelect: (AnnotationMark) -> Void

    init(mapPoints: [MapPoint], onSelect: @escaping (AnnotationMark) -> Void) {
        self.mapPoints = mapPoints
        self.onSelect = onSelect
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapRepresentable

        init(_ parent: MapRepresentable) {
            self.parent = parent
        }

        func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let cluster = annotation as? MKClusterAnnotation else {
                return createAnnotationView(for: annotation)
            }
            return createClusterAnnotationView(for: cluster)
        }

        func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? AnnotationMark {
                print("Marker tapped! Name: \(annotation.name), Address: \(annotation.address)")
                DispatchQueue.main.async {
                    self.parent.onSelect(annotation)
                }
            }
        }

        func mapView(
            _: MKMapView,
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
//        mapView.setRegion(locationManager.region, animated: false)
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context _: Context) {
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let clusterID = "clustering"
