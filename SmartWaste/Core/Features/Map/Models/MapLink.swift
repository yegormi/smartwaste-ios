//
//  MapLink.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 09.12.2023.
//

import UIKit
import CoreLocation

enum MapLink: Equatable {
    case appleMaps
    case googleMaps

    var openURL: URL? {
        switch self {
        case .appleMaps:
            return URL(string: "maps://")
        case .googleMaps:
            return URL(string: "comgooglemaps://")
        }
    }

    func open(with coordinates: CLLocationCoordinate2D) {
        guard let baseURL = openURL else {
            print("Invalid map application")
            return
        }

        let urlString: String
        switch self {
        case .appleMaps:
            urlString = "\(baseURL.absoluteString)?daddr=\(coordinates.latitude),\(coordinates.longitude)"
        case .googleMaps:
            urlString = "\(baseURL.absoluteString)?saddr=&daddr=\(coordinates.latitude),\(coordinates.longitude)&directionsmode=driving"
        }

        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Unable to open map application")
        }
    }
}
