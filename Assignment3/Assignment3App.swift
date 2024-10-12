//
//  Assignment3App.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import SwiftUI
import Firebase
@main

struct Assignment3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dogManager = DogManager()
    @StateObject var firestoreManager = FirestoreManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dogManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(firestoreManager)
            
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
