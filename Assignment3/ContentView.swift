//
//  ContentView.swift
//  Assignment3
//
//  Created by thomas on 8/10/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var shouldRefresh = false

    var body: some View {
        NavigationStack {
            MainView()
                .environmentObject(firestoreManager)
                .onAppear {
                    firestoreManager.fetchDog {
                    }
                }
                .applyBackground()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
            .environmentObject(FirestoreManager())
    }
}
