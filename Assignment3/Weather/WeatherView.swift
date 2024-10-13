//
//  WeatherView.swift
//  Assignment3
//
//  Created by thomas on 12/10/2024.
//

import Foundation
import SwiftUI
import CoreLocation

struct WeatherView: View {
    @ObservedObject var weatherAPIManager = WeatherAPIManager()
    @StateObject private var locationManager = LocationManager()
    @State private var lastFetchedLocation: CLLocationCoordinate2D?

    var body: some View {
        VStack(alignment: .leading) {
            if let weather = weatherAPIManager.weatherData {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weather in \(weather.location.name)")
                        .font(.title)
                        .padding(.top)

                    Text("Current Temperature: \(weather.current.temp_c, specifier: "%.1f")°C")
                        .font(.headline)

                    Text("Condition: \(weather.current.condition.text)")
                        .font(.subheadline)
                }
                .padding()

                Divider()

                // Hourly Forecast Section
                Text("Hourly Forecast")
                    .font(.title2)
                    .padding([.top, .leading])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        if let currentHour = getCurrentHourIndex(for: weather) {
                            let hours = Array(weather.forecast.forecastday.first?.hour[currentHour...] ?? []) +
                                Array(weather.forecast.forecastday.first?.hour[0..<currentHour] ?? [])

                            ForEach(hours, id: \.time) { hour in
                                VStack(spacing: 8) {
                                    Text(formatHourString(hour.time))
                                        .font(.subheadline)

                                    // Display SF Symbol based on weather condition
                                    Image(systemName: mapWeatherConditionToSymbol(condition: hour.condition.text))
                                        .font(.largeTitle)

                                    Text("\(hour.temp_c, specifier: "%.1f")°C")
                                        .font(.headline)

                                    // Rain forecast
                                    if let chanceOfRain = hour.chance_of_rain {
                                        Text("Rain: \(chanceOfRain)%")
                                            .font(.subheadline)
                                            .foregroundColor(chanceOfRain > 50 ? .blue : .gray)
                                    }
                                }
                                .frame(width: 80)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding([.leading, .bottom])
                }

                Spacer()
            } else {
                ProgressView("Loading weather data...")
                    .font(.headline)
                    .padding()
            }
        }
        .onAppear {
            if let location = locationManager.location {
                lastFetchedLocation = location
                weatherAPIManager.fetchWeather(for: location.latitude, longitude: location.longitude)
            } else {
                locationManager.requestLocation()
            }
        }
        .onReceive(locationManager.$location) { newLocation in
            if let newLocation = newLocation {
                if let lastLocation = lastFetchedLocation {
                    if newLocation.latitude != lastLocation.latitude || newLocation.longitude != lastLocation.longitude {
                        lastFetchedLocation = newLocation
                        weatherAPIManager.fetchWeather(for: newLocation.latitude, longitude: newLocation.longitude)
                    }
                } else {
                    lastFetchedLocation = newLocation
                    weatherAPIManager.fetchWeather(for: newLocation.latitude, longitude: newLocation.longitude)
                }
            }
        }
    }

    private func getCurrentHourIndex(for weather: WeatherData) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let currentDate = Date()

        for (index, hour) in weather.forecast.forecastday.first?.hour.enumerated() ?? [].enumerated() {
            if let hourDate = formatter.date(from: hour.time), Calendar.current.isDate(hourDate, equalTo: currentDate, toGranularity: .hour) {
                return index
            }
        }

        return nil
    }

    private func formatHourString(_ hourString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        if let date = formatter.date(from: hourString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h a"
            return outputFormatter.string(from: date)
        }

        return hourString
    }

    // Function to map weather condition to an appropriate SF Symbol
    private func mapWeatherConditionToSymbol(condition: String) -> String {
        let lowercasedCondition = condition.lowercased()

        switch lowercasedCondition {
        case let condition where condition.contains("sunny"):
            return "sun.max.fill"
        case let condition where condition.contains("cloudy"):
            return "cloud.fill"
        case let condition where condition.contains("rain"):
            return "cloud.rain.fill"
        case let condition where condition.contains("thunder"):
            return "cloud.bolt.fill"
        case let condition where condition.contains("snow"):
            return "snow"
        case let condition where condition.contains("clear"):
            return "moon.stars.fill" // for clear nights
        default:
            return "cloud"
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
