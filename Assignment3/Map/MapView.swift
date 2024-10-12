//
//  MapView.swift
//  Assignment3
//
//  Created by thomas on 9/10/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D? // Binding to pass the selected location back
    @Binding var isPresented: Bool // New binding to track dismissal of the map
    @ObservedObject var locationManager = LocationManager() // Use LocationManager for real-time updates
    
    @State private var annotations: [Location] = [] // Array to hold location annotations
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $locationManager.region, interactionModes: .all, showsUserLocation: true, annotationItems: annotations) { location in
                MapMarker(coordinate: location.coordinate, tint: .blue)
            }
            .frame(height: 700)
            .onTapGesture(coordinateSpace: .global) { location in
                handleMapTap(location: location) // Handle map tap with coordinate location
            }
            
            if selectedLocation != nil {
                Spacer()

                Button("Confirm Location") {
                    confirmLocation()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("Tap the map to select a location")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onAppear {
#if !DEBUG
locationManager.requestLocation() // Request location only when not in preview
#endif
        }
    }

    // Handle user tapping on the map to select a location
    private func handleMapTap(location: CGPoint) {
        let mapLocation = locationManager.region.center // Get the current map region's center
        selectedLocation = mapLocation
        annotations = [Location(coordinate: mapLocation)] // Add the selected location as an annotation
    }
    
    private func confirmLocation() {
        // Dismiss the map by setting isPresented to false
        isPresented = false
    }
}



struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            selectedLocation: .constant(CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.209900)),
            isPresented: .constant(true)
        )
            .environmentObject(LocationManager()) // Static mock location for previews
    }
}
