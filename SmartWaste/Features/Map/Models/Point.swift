//
//  Point.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 14.11.2023.
//

import Foundation
import CoreLocation

struct Point: Identifiable, Codable {
    let id: String
    let lat: Double
    let lng: Double
    let name: String
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
