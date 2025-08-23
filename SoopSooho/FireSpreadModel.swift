//
//  FireSpreadModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import Foundation
import SwiftUI

// Wildfire History Data Model
struct FireHistory {
    let fireDate: Date
    let burnedArea: Double // Burned Area (ha)
    let suppressionDate: Date? // Suppression Completion Date (nil = not suppressed)
    let fireIntensity: FireIntensity
    let location: FireLocation
}

enum FireIntensity: String, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"
    
    var riskMultiplier: Double {
        switch self {
        case .low: return 1.2
        case .moderate: return 1.5
        case .high: return 2.0
        case .extreme: return 3.0
        }
    }
}

struct FireLocation {
    let latitude: Double
    let longitude: Double
    let radius: Double // Impact Radius (km)
}

// Geographic Data Model
struct GeographicData {
    let elevation: Int // Elevation (m)
    let slope: Double // Slope (°)
    let aspect: String // Aspect (N, S, E, W, NE, SE, SW, NW)
    let vegetationType: VegetationType
    let fuelLoad: Double // Fuel Load (ton/ha)
}

enum VegetationType: String, CaseIterable {
    case pine = "Pine Forest"
    case oak = "Oak Forest"
    case mixed = "Mixed Forest"
    case grassland = "Grassland"
    case shrub = "Shrubland"
    
    var flammability: Double {
        switch self {
        case .pine: return 0.9
        case .oak: return 0.6
        case .mixed: return 0.7
        case .grassland: return 0.8
        case .shrub: return 0.75
        }
    }
    
    var color: Color {
        switch self {
        case .pine: return .green
        case .oak: return Color.brown
        case .mixed: return Color.mint
        case .grassland: return Color.yellow.opacity(0.7)
        case .shrub: return Color.orange.opacity(0.6)
        }
    }
}

// Soil Data Model
struct SoilData {
    let moistureContent: Double // Surface Soil Moisture (%)
    let deepSoilMoisture: Double // Deep Soil Moisture (20–50 cm depth, %)
    let organicMatter: Double // Organic Matter (%)
    let soilType: SoilType
    let depth: Double // Organic Layer Depth (cm)
    let recentFireHistory: [FireHistory] // Recent Fire History
    
    // ZFRI Calculation (Zombie Fire Risk Index)
    var zfriScore: Double {
        let deepSoilDeficit = 1.0 - (deepSoilMoisture / 100.0) // Deep Soil Dryness
        let organicFactor = min(organicMatter / 100.0, 1.0) // Organic Matter Ratio
        let burnHistoryWeight = calculateBurnHistoryWeight() // Fire History Weight
        
        return deepSoilDeficit * organicFactor * burnHistoryWeight
    }
    
    // ZFRI Score → Risk Level
    var zfriRiskLevel: ZombieFireRisk {
        let score = zfriScore
        switch score {
        case 0.8...: return .veryHigh
        case 0.6..<0.8: return .high
        case 0.4..<0.6: return .medium
        case 0.2..<0.4: return .low
        default: return .veryLow
        }
    }
    
    // Recent Fire History Weight
    private func calculateBurnHistoryWeight() -> Double {
        let currentDate = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        
        let recentFires = recentFireHistory.filter { fire in
            fire.fireDate >= oneMonthAgo
        }
        
        if recentFires.isEmpty {
            return 1.0
        }
        
        var totalWeight = 1.0
        for fire in recentFires {
            let intensityMultiplier = fire.fireIntensity.riskMultiplier
            let suppressionFactor = fire.suppressionDate == nil ? 2.0 : 1.3
            let daysSinceFire = Calendar.current.dateComponents([.day], from: fire.fireDate, to: currentDate).day ?? 30
            let timeFactor = max(0.1, 1.0 - (Double(daysSinceFire) / 30.0))
            
            totalWeight += (intensityMultiplier * suppressionFactor * timeFactor)
        }
        
        return min(totalWeight, 5.0)
    }
}

enum SoilType: String, CaseIterable {
    case peat = "Peat"
    case humus = "Humus"
    case clay = "Clay"
    case sand = "Sand"
    case loam = "Loam"
    
    var zombieFirePotential: Double {
        switch self {
        case .peat: return 0.95
        case .humus: return 0.8
        case .clay: return 0.2
        case .sand: return 0.3
        case .loam: return 0.5
        }
    }
}

enum ZombieFireRisk: String, CaseIterable {
    case veryHigh = "Very High"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case veryLow = "Very Low"
    
    var color: Color {
        switch self {
        case .veryHigh: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .veryLow: return .green
        }
    }
    
    var riskValue: Double {
        switch self {
        case .veryHigh: return 0.9
        case .high: return 0.7
        case .medium: return 0.5
        case .low: return 0.3
        case .veryLow: return 0.1
        }
    }
}

// Weather Data Model
struct WeatherData {
    let windDirection: WindDirection
    let windSpeed: Double
    let temperature: Int
    let humidity: Int
    let precipitation: Double // Precipitation (mm)
    let droughtIndex: Double // Drought Index (0–1)
}

enum WindDirection: String, CaseIterable {
    case north = "North"
    case northeast = "Northeast"
    case east = "East"
    case southeast = "Southeast"
    case south = "South"
    case southwest = "Southwest"
    case west = "West"
    case northwest = "Northwest"
    
    var angle: Double {
        switch self {
        case .north: return 90
        case .northeast: return 135
        case .east: return 180
        case .southeast: return 225
        case .south: return 270
        case .southwest: return 315
        case .west: return 0
        case .northwest: return 45
        }
    }
    
    var symbol: String {
        switch self {
        case .north: return "↓"
        case .northeast: return "↙"
        case .east: return "←"
        case .southeast: return "↖"
        case .south: return "↑"
        case .southwest: return "↗"
        case .west: return "→"
        case .northwest: return "↘"
        }
    }
}

// Spread Prediction Point
struct SpreadPoint {
    let id = UUID()
    var x: Double
    var y: Double
    var intensity: Double // Fire Intensity (0–1)
    var arrivalTime: Double // Arrival Time (min)
    var isZombieFire: Bool // Zombie Fire
}

// Extended Fire Risk Area Model
struct EnhancedFireRiskArea {
    let id = UUID()
    let name: String
    let riskLevel: Int
    let weatherData: WeatherData
    let geographicData: GeographicData
    let soilData: SoilData
    let lastUpdated: Date
    
    // Overall Risk Score
    var overallRiskScore: Double {
        let weatherRisk = calculateWeatherRisk()
        let geographicRisk = calculateGeographicRisk()
        let soilRisk = soilData.zfriRiskLevel.riskValue
        return weatherRisk * 0.4 + geographicRisk * 0.4 + soilRisk * 0.2
    }
    
    func calculateWeatherRisk() -> Double {
        let tempFactor = min(Double(weatherData.temperature) / 40.0, 1.0)
        let humidityFactor = 1.0 - (Double(weatherData.humidity) / 100.0)
        let windFactor = min(weatherData.windSpeed / 15.0, 1.0)
        let droughtFactor = weatherData.droughtIndex
        return (tempFactor + humidityFactor + windFactor + droughtFactor) / 4.0
    }
    
    func calculateGeographicRisk() -> Double {
        let slopeFactor = min(geographicData.slope / 45.0, 1.0)
        let vegetationFactor = geographicData.vegetationType.flammability
        let fuelFactor = min(geographicData.fuelLoad / 50.0, 1.0)
        return (slopeFactor + vegetationFactor + fuelFactor) / 3.0
    }
}

// Simulation Result Model
struct SimulationResult {
    let spreadPoints: [SpreadPoint]
    let affectedArea: Double // Affected Area (ha)
    let maxSpreadDistance: Double // Max Spread Distance (m)
    let zombieFireLocations: [SpreadPoint]
    let estimatedDuration: Int // Estimated Duration (hours)
    let suppressionDifficulty: SuppressionDifficulty
}

enum SuppressionDifficulty: String, CaseIterable {
    case veryEasy = "Very Easy"
    case easy = "Easy"
    case moderate = "Moderate"
    case difficult = "Difficult"
    case veryDifficult = "Very Difficult"
    
    var color: Color {
        switch self {
        case .veryEasy: return .green
        case .easy: return .mint
        case .moderate: return .yellow
        case .difficult: return .orange
        case .veryDifficult: return .red
        }
    }
}
