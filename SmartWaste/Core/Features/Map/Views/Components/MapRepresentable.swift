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
    let completion: (AnnotationMark) -> Void
    
    init(mapPoints: [MapPoint], completion: @escaping (AnnotationMark) -> Void) {
        self.mapPoints = mapPoints
        self.completion = completion
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context _: Context) {
        let annotations = mapPoints.map { createAnnotation(from: $0) }
        updateAnnotations(on: uiView, with: annotations)
    }
    
    func updateAnnotations(on mapView: MKMapView, with newAnnotations: [AnnotationMark]) {
        // Get the set of current annotation identifiers
        let currentAnnotationTitles = mapView.annotations.compactMap { ($0 as? AnnotationMark)?.name ?? "" }
        
        // Get the set of new annotation identifiers
        let newAnnotationTitles = newAnnotations.map { $0.name }
        
        // Calculate annotations to remove
        let annotationsToRemove = mapView.annotations.filter { annotation in
            guard let annotationMark = annotation as? AnnotationMark else { return false }
            return !newAnnotationTitles.contains(annotationMark.name)
        }
        mapView.removeAnnotations(annotationsToRemove)
        
        // Calculate annotations to add
        let annotationsToAdd = newAnnotations.filter { annotation in
            return !currentAnnotationTitles.contains(annotation.name)
        }
        mapView.addAnnotations(annotationsToAdd)
    }

    private func createAnnotation(from point: MapPoint) -> AnnotationMark {
        return AnnotationMark(
            coordinate: point.coordinate,
            name: point.name,
            address: point.address,
            emojiList: point.categories.map { $0.emoji }
        )
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
            guard let annotation = view.annotation as? AnnotationMark else { return }
            self.parent.completion(annotation)
            print("Tapped: \(annotation.name)")
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
