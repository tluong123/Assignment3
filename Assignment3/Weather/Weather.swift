//
//  Weather.swift
//  Assignment3
//
//  Created by thomas on 12/10/2024.
//

import Foundation

struct WeatherData: Codable {
    let location: WeatherLocation
    let current: CurrentWeather
    let forecast: WeatherForecast
}

struct WeatherLocation: Codable {
    let name: String
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
}

struct WeatherForecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let hour: [HourWeather]
}

struct HourWeather: Codable {
    let time: String
    let temp_c: Double
    let chance_of_rain: Int?
    let condition: WeatherCondition
}
