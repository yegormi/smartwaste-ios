//
//  MapPoint.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import CoreLocation
import Foundation

struct MapPoint: Codable, Identifiable, Equatable {
    let id: Int
    let lat: Double
    let lng: Double
    let name: String
    let address: String
    let categories: [BucketCategory]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
