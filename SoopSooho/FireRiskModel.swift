//
//  FireRiskModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import Foundation
import SwiftUICore

struct FireRiskArea {
    let id = UUID()
    let name: String
    let riskLevel: Int // 1-5 (5 = most dangerous)
    let temperature: Int
    let humidity: Int
    let windSpeed: Double
    let lastUpdated: Date
    
    // Extended data
    let enhancedData: EnhancedFireRiskArea
}

class FireRiskViewModel: ObservableObject {
    @Published var topRiskAreas: [FireRiskArea] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Normally this would come from an API
        topRiskAreas = [
            FireRiskArea(
                name: "Buk-myeon, Uljin-gun",
                riskLevel: 5,
                temperature: 32,
                humidity: 15,
                windSpeed: 8.5,
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "Buk-myeon, Uljin-gun",
                    riskLevel: 5,
                    weatherData: WeatherData(
                        windDirection: .southwest,
                        windSpeed: 8.5,
                        temperature: 32,
                        humidity: 15,
                        precipitation: 0.0,
                        droughtIndex: 0.85
                    ),
                    geographicData: GeographicData(
                        elevation: 450,
                        slope: 25.0,
                        aspect: "Southwest",
                        vegetationType: .pine,
                        fuelLoad: 35.2
                    ),
                    soilData: SoilData(
                        moistureContent: 8.5,
                        deepSoilMoisture: 5.2, // deeper soil is drier
                        organicMatter: 15.2,
                        soilType: .humus,
                        depth: 12.5,
                        recentFireHistory: [
                            FireHistory(
                                fireDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                                burnedArea: 2.3,
                                suppressionDate: nil, // not fully extinguished
                                fireIntensity: .high,
                                location: FireLocation(latitude: 36.9, longitude: 129.4, radius: 0.5)
                            )
                        ]
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "Imha-myeon, Andong-si",
                riskLevel: 4,
                temperature: 29,
                humidity: 22,
                windSpeed: 6.2,
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "Imha-myeon, Andong-si",
                    riskLevel: 4,
                    weatherData: WeatherData(
                        windDirection: .west,
                        windSpeed: 6.2,
                        temperature: 29,
                        humidity: 22,
                        precipitation: 0.5,
                        droughtIndex: 0.72
                    ),
                    geographicData: GeographicData(
                        elevation: 320,
                        slope: 18.5,
                        aspect: "West",
                        vegetationType: .mixed,
                        fuelLoad: 28.7
                    ),
                    soilData: SoilData(
                        moistureContent: 12.3,
                        deepSoilMoisture: 8.7,
                        organicMatter: 11.8,
                        soilType: .loam,
                        depth: 8.2,
                        recentFireHistory: [] // no recent fire history
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "Chunyang-myeon, Bonghwa-gun",
                riskLevel: 3,
                temperature: 26,
                humidity: 35,
                windSpeed: 4.8,
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "Chunyang-myeon, Bonghwa-gun",
                    riskLevel: 3,
                    weatherData: WeatherData(
                        windDirection: .northwest,
                        windSpeed: 4.8,
                        temperature: 26,
                        humidity: 35,
                        precipitation: 1.5,
                        droughtIndex: 0.45
                    ),
                    geographicData: GeographicData(
                        elevation: 580,
                        slope: 22.0,
                        aspect: "Northwest",
                        vegetationType: .mixed,
                        fuelLoad: 28.3
                    ),
                    soilData: SoilData(
                        moistureContent: 18.2,
                        deepSoilMoisture: 14.8,
                        organicMatter: 12.1,
                        soilType: .loam,
                        depth: 8.5,
                        recentFireHistory: [
                            FireHistory(
                                fireDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
                                burnedArea: 1.7,
                                suppressionDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                                fireIntensity: .moderate,
                                location: FireLocation(latitude: 36.8, longitude: 128.9, radius: 0.3)
                            )
                        ]
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "Yeonghae-myeon, Yeongdeok-gun",
                riskLevel: 3,
                temperature: 28,
                humidity: 28,
                windSpeed: 5.8,
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "Yeonghae-myeon, Yeongdeok-gun",
                    riskLevel: 3,
                    weatherData: WeatherData(
                        windDirection: .east,
                        windSpeed: 5.8,
                        temperature: 28,
                        humidity: 28,
                        precipitation: 1.2,
                        droughtIndex: 0.55
                    ),
                    geographicData: GeographicData(
                        elevation: 180,
                        slope: 12.5,
                        aspect: "East",
                        vegetationType: .oak,
                        fuelLoad: 22.3
                    ),
                    soilData: SoilData(
                        moistureContent: 18.7,
                        deepSoilMoisture: 15.3,
                        organicMatter: 8.9,
                        soilType: .clay,
                        depth: 5.4,
                        recentFireHistory: [] // no recent fire history
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "Jinbo-myeon, Cheongsong-gun",
                riskLevel: 3,
                temperature: 27,
                humidity: 31,
                windSpeed: 4.9,
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "Jinbo-myeon, Cheongsong-gun",
                    riskLevel: 3,
                    weatherData: WeatherData(
                        windDirection: .south,
                        windSpeed: 4.9,
                        temperature: 27,
                        humidity: 31,
                        precipitation: 2.1,
                        droughtIndex: 0.48
                    ),
                    geographicData: GeographicData(
                        elevation: 420,
                        slope: 22.0,
                        aspect: "South",
                        vegetationType: .shrub,
                        fuelLoad: 18.9
                    ),
                    soilData: SoilData(
                        moistureContent: 22.1,
                        deepSoilMoisture: 19.8,
                        organicMatter: 6.7,
                        soilType: .sand,
                        depth: 4.2,
                        recentFireHistory: [] // no recent fire history
                    ),
                    lastUpdated: Date()
                )
            )
        ]
    }
    
    func getRiskLevelColor(_ level: Int) -> Color {
        switch level {
        case 5: return .red
        case 4: return .orange
        case 3: return .yellow
        case 2: return .blue
        default: return .green
        }
    }
    
    func getRiskLevelText(_ level: Int) -> String {
        switch level {
        case 5: return "Very High"
        case 4: return "High"
        case 3: return "Moderate"
        case 2: return "Low"
        default: return "Safe"
        }
    }
}
