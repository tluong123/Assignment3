//
//  WeatherAPIManager.swift
//  Assignment3
//
//  Created by thomas on 12/10/2024.
//

import Foundation
import CoreLocation

class WeatherAPIManager: ObservableObject {
    @Published var weatherData: WeatherData?

    private let apiKey = "4359ed526c4747adafe95946241210" // Direct API key for testing
    private let cacheKey = "cachedWeatherData"
    private let cacheExpiryKey = "cachedWeatherExpiry"
    
    private let expiryTimeInSeconds: TimeInterval = 3600 // 1-hour cache expiry time

    func fetchWeather(for latitude: Double, longitude: Double, forceRefresh: Bool = false) {
        guard !apiKey.isEmpty else {
            print("API key is missing!")
            return
        }
        
        // Load cached data if available and not expired, unless a refresh is forced
        if !forceRefresh {
            if loadCachedWeatherData() {
                // Return if cached data was successfully loaded
                return
            }
        }

        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=1&hourly=1"
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print the raw JSON data as a string for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = decodedData
                    // Cache the new weather data
                    self.cacheWeatherData(decodedData)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }

        task.resume()
    }

    private func loadCachedWeatherData() -> Bool {
        // Check cache expiry
        if let lastFetchTime = UserDefaults.standard.object(forKey: cacheExpiryKey) as? Date,
           Date().timeIntervalSince(lastFetchTime) < expiryTimeInSeconds,
           let cachedData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedWeather = try? JSONDecoder().decode(WeatherData.self, from: cachedData) {
            DispatchQueue.main.async {
                self.weatherData = cachedWeather
                print("Loaded cached weather data successfully.")
            }
            return true
        } else {
            print("Cache expired or missing. Fetching new data...")
            return false
        }
    }

    private func cacheWeatherData(_ weather: WeatherData) {
        // Encode and cache weather data
        if let encodedData = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encodedData, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheExpiryKey) // Save the time of fetching
            print("Weather data cached successfully")
        } else {
            print("Failed to encode and cache weather data")
        }
    }

    // Function to manually refresh weather data
    func refreshWeather(for latitude: Double, longitude: Double) {
        fetchWeather(for: latitude, longitude: longitude, forceRefresh: true)
    }
}
