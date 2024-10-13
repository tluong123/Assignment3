//
//  Background.swift
//  Assignment3
//
//  Created by thomas on 13/10/2024.
//

import SwiftUI

struct Background: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.green.opacity(0.3) // Use Apple's mint color for light green background
                .ignoresSafeArea()

            Image("paw")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.05)
                .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func applyBackground() -> some View {
        self.modifier(Background())
    }
}
