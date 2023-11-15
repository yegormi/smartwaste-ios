////
////  MapView.swift
////  SmartWaste
////
////  Created by Yegor Myropoltsev on 14.11.2023.
////
//
////import MapKit
////import SwiftUI
////
////struct MapView: View {
////    @EnvironmentObject var authVM: AuthViewModel
////    @StateObject var manager = LocationManager()
////    @State private var selectedPoint: Point?
////
////    var body: some View {
////        Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: authVM.points) { point in
////            MapAnnotation(coordinate: point.coordinate) {
////                Circle()
////                    .fill(Color.white.opacity(0.9))
////                    .overlay {
////                        Text("♻️")
////                            .font(.system(size: 20))
////                            .onTapGesture {
////                                selectedPoint = point
////                            }
////                    }
////                    .frame(width: 30, height: 30)
////            }
////        }
////        .onAppear {
////            authVM.getPoints(token: authVM.response?.accessToken ?? "")
////        }
////        .popover(item: $selectedPoint) { point in
////            VStack {
////                Text(point.name)
////                    .font(.headline)
////                Text(point.address)
////                    .foregroundColor(.secondary)
////            }
////            .padding()
////        }
////    }
////}
////
////struct MapView_Previews: PreviewProvider {
////    static var previews: some View {
////        MapView()
////            .environmentObject(AuthViewModel())
////    }
////}
//
//import SwiftUI
//import MapKit
//
//struct MapViewRepresentable: UIViewRepresentable {
//    @EnvironmentObject var authVM: AuthViewModel
//    @StateObject var manager = LocationManager()
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapViewRepresentable
//
//        init(_ parent: MapViewRepresentable) {
//            self.parent = parent
//        }
//
//        /// Showing annotation on the map
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            guard let annotation = annotation as? LandmarkAnnotation else { return nil }
//            return AnnotationView(annotation: annotation, reuseIdentifier: AnnotationView.ReuseID)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(manager.region, animated: false)
//        mapView.mapType = .standard
//        mapView.showsUserLocation = true
//
//        // Add annotations
//        for point in authVM.points {
//            let annotation = LandmarkAnnotation(coordinate: point.coordinate)
//            mapView.addAnnotation(annotation)
//        }
//
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // Handle updates if needed
//    }
//}
//
//class LandmarkAnnotation: NSObject, MKAnnotation {
//    let coordinate: CLLocationCoordinate2D
//
//    init(coordinate: CLLocationCoordinate2D) {
//        self.coordinate = coordinate
//        super.init()
//    }
//}
//
///// Here possible to customize annotation view
//let clusterID = "clustering"
//
//class AnnotationView: MKMarkerAnnotationView {
//    static let ReuseID = "cultureAnnotation"
//
//    /// Setting the key for clustering annotations
//    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = clusterID
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func prepareForDisplay() {
//        super.prepareForDisplay()
//        displayPriority = .defaultLow
//    }
//}
//
//struct MapView: View {
//    @EnvironmentObject var authVM: AuthViewModel
//    @State private var selectedPoint: Point?
//
//    var body: some View {
//        MapViewRepresentable()
//            .onAppear {
//                authVM.getPoints(token: authVM.response?.accessToken ?? "")
//            }
//            .popover(item: $selectedPoint) { point in
//                VStack {
//                    Text(point.name)
//                        .font(.headline)
//                    Text(point.address)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//            }
//    }
//}
//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//            .environmentObject(AuthViewModel())
//    }
//}
