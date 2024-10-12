//
//  Location.swift
//  Assignment3
//
//  Created by thomas on 9/10/2024.
//

import SwiftUI
import MapKit

// Location struct to hold coordinate
struct Location: Identifiable {
    let id = UUID() // Each location needs a unique identifier
    var coordinate: CLLocationCoordinate2D
}

// TaskLocationManager to load task locations
class TaskLocationManager: ObservableObject {
    @Published var taskLocations: [Location] = []
    var tasks: [TaskEntity]

    init(tasks: [TaskEntity]) {
        self.tasks = tasks
        loadTaskLocations()
    }

    // Function to load task locations from TaskEntity
    private func loadTaskLocations() {
        taskLocations = tasks.compactMap { task in
            let latitude = task.latitude
            let longitude = task.longitude
            return Location(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
    }
}
// MapView for displaying task locations
struct TaskLocationMapView: View {
    @Binding var taskLocations: [Location]
    @Environment(\.presentationMode) var presentationMode
    @State private var sydneyRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -33.865143, longitude: 151.209900),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                Map(coordinateRegion: $sydneyRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: taskLocations) { location in
                    MapMarker(coordinate: location.coordinate, tint: .blue)
                }
                .frame(height: 600)
                .navigationTitle("Your Activities")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label("Back", systemImage: "arrow.left")
                        }
                    }
                }
            }
        }
    }
}
