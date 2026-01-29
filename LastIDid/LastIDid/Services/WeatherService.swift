//
//  WeatherService.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/21/26.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Weather Condition

enum WeatherCondition: String, CaseIterable {
    case sunny
    case partlyCloudy
    case cloudy
    case rainy
    case thunderstorm
    case snowy
    case foggy
    case windy
    case extremeHeat
    case extremeCold

    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .partlyCloudy: return "⛅"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .thunderstorm: return "⛈️"
        case .snowy: return "🌨️"
        case .foggy: return "🌫️"
        case .windy: return "💨"
        case .extremeHeat: return "🌡️"
        case .extremeCold: return "❄️"
        }
    }

    var description: String {
        switch self {
        case .sunny: return "Sunny"
        case .partlyCloudy: return "Partly Cloudy"
        case .cloudy: return "Cloudy"
        case .rainy: return "Rainy"
        case .thunderstorm: return "Thunderstorm"
        case .snowy: return "Snowy"
        case .foggy: return "Foggy"
        case .windy: return "Windy"
        case .extremeHeat: return "Very Hot"
        case .extremeCold: return "Very Cold"
        }
    }
}

// MARK: - Weather Data

struct WeatherData {
    let condition: WeatherCondition
    let temperatureFahrenheit: Double
    let temperatureCelsius: Double
    let lastUpdated: Date

    var emoji: String { condition.emoji }
    var description: String { condition.description }

    func temperatureString(useCelsius: Bool) -> String {
        if useCelsius {
            return "\(Int(temperatureCelsius))°C"
        } else {
            return "\(Int(temperatureFahrenheit))°F"
        }
    }
}

// MARK: - Weather Service

@MainActor
class WeatherService: NSObject, ObservableObject {
    static let shared = WeatherService()

    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLocationPermission = false

    private let locationManager = CLLocationManager()
    private var lastFetchLocation: CLLocation?
    private var lastFetchTime: Date?

    // Cache weather for 30 minutes
    private let cacheInterval: TimeInterval = 1800

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkLocationPermission()
    }

    // MARK: - Location Permission

    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            hasLocationPermission = true
        case .notDetermined:
            hasLocationPermission = false
        case .denied, .restricted:
            hasLocationPermission = false
        @unknown default:
            hasLocationPermission = false
        }
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Fetch Weather

    func fetchWeather() async {
        // Check if we have cached data that's still valid
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheInterval,
           currentWeather != nil {
            return // Use cached data
        }

        guard hasLocationPermission else {
            // Generate demo weather if no permission
            generateDemoWeather()
            return
        }

        isLoading = true
        errorMessage = nil

        // Request location
        locationManager.requestLocation()
    }

    // MARK: - Generate Weather Data

    private func generateWeatherFromLocation(_ location: CLLocation) {
        // In a real app, you would call WeatherKit or an API here
        // For now, we'll generate realistic demo weather based on time of day and season

        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let hour = calendar.component(.hour, from: Date())

        // Determine season-appropriate temperature ranges
        let (minTemp, maxTemp): (Double, Double)
        switch month {
        case 12, 1, 2: // Winter
            minTemp = 25
            maxTemp = 50
        case 3, 4, 5: // Spring
            minTemp = 45
            maxTemp = 70
        case 6, 7, 8: // Summer
            minTemp = 65
            maxTemp = 95
        case 9, 10, 11: // Fall
            minTemp = 40
            maxTemp = 65
        default:
            minTemp = 50
            maxTemp = 75
        }

        // Adjust for time of day
        let tempAdjustment: Double
        switch hour {
        case 0..<6: tempAdjustment = -10 // Night
        case 6..<9: tempAdjustment = -5  // Morning
        case 9..<16: tempAdjustment = 5  // Day
        case 16..<20: tempAdjustment = 0 // Evening
        default: tempAdjustment = -8     // Late night
        }

        let baseTemp = Double.random(in: minTemp...maxTemp)
        let tempF = min(max(baseTemp + tempAdjustment, 0), 110)
        let tempC = (tempF - 32) * 5 / 9

        // Determine weather condition
        let condition: WeatherCondition
        if tempF > 95 {
            condition = .extremeHeat
        } else if tempF < 32 {
            condition = month >= 11 || month <= 2 ? .snowy : .extremeCold
        } else {
            // Random weather with seasonal weighting
            let rand = Double.random(in: 0...1)
            switch month {
            case 6, 7, 8: // Summer - more sunny
                if rand < 0.6 { condition = .sunny }
                else if rand < 0.8 { condition = .partlyCloudy }
                else if rand < 0.9 { condition = .thunderstorm }
                else { condition = .cloudy }
            case 12, 1, 2: // Winter - more cloudy/snowy
                if rand < 0.2 { condition = .sunny }
                else if rand < 0.4 { condition = .partlyCloudy }
                else if rand < 0.6 { condition = .cloudy }
                else if rand < 0.8 { condition = .snowy }
                else { condition = .foggy }
            default: // Spring/Fall - mixed
                if rand < 0.3 { condition = .sunny }
                else if rand < 0.5 { condition = .partlyCloudy }
                else if rand < 0.7 { condition = .cloudy }
                else if rand < 0.85 { condition = .rainy }
                else { condition = .foggy }
            }
        }

        currentWeather = WeatherData(
            condition: condition,
            temperatureFahrenheit: tempF,
            temperatureCelsius: tempC,
            lastUpdated: Date()
        )

        lastFetchLocation = location
        lastFetchTime = Date()
        isLoading = false
    }

    private func generateDemoWeather() {
        // Generate demo weather without location
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194) // SF default
        generateWeatherFromLocation(location)
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            generateWeatherFromLocation(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorMessage = "Unable to get location"
            isLoading = false
            // Fall back to demo weather
            generateDemoWeather()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationPermission()
            if hasLocationPermission {
                await fetchWeather()
            }
        }
    }
}
