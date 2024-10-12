//
//  LocationManager.swift
//  Assignment3
//
//  Created by thomas on 9/10/2024.
//

import MapKit
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion()

    private var locationManager = CLLocationManager()

    override init() {
        super.init()

        // Check if running in Xcode Preview mode
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Provide a mock location for previews
            self.location = CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.209900) // Mock location: San Francisco
            self.region = MKCoordinateRegion(
                center: self.location!,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            return
        }
        #endif

        // For real device/simulator, set up the actual location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            self.location = location
            self.region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user’s location: \(error.localizedDescription)")
    }
}
