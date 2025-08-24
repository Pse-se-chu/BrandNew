//
//  FireRiskModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//  Updated with 3-Layer NDWI Integration
//

import Foundation
import SwiftUI

// MARK: - 3-Layer Fire Risk Calculator Data Models
struct SimpleWeatherData {
    let temperature: Double      // 온도 (°C)
    let humidity: Double        // 습도 (%)
    let windSpeed: Double       // 풍속 (m/s)
    let precipitation: Double   // 강수량 (mm)
}

struct HumanActivityData {
    let populationDensity: Double    // 인구밀도 (명/km²)
    let hikingTrails: Int           // 등산로 개수
    let residentialProximity: Double // 주거지 거리 (km)
    let dayOfWeek: Int              // 요일 (0=월, 6=일)
}

struct ForestNDWIData {
    let coniferRatio: Double    // 침엽수 비율 (0-1)
    let ndwiValue: Double       // NDWI 지수 (-1 ~ 1)
    let slope: Double           // 경사도 (도)
    let elevation: Double       // 고도 (m)
}

struct FireRiskCalculationResult {
    let totalRisk: Double
    let kfsRisk: Double
    let humanRisk: Double
    let forestRisk: Double
    let riskLevel: String
    let ndwiValue: Double
}

class FireRiskCalculator {
    // Azure ML 최적화 가중치
    private let layerWeights = [
        "kfs_index": 0.4,
        "human_activity": 0.3,
        "forest_ndwi": 0.3
    ]
    
    func calculateKFSIndex(weather: SimpleWeatherData) -> Double {
        // 실효습도 계산
        let effectiveHumidity = weather.humidity * (1 - 0.01 * weather.temperature)
        
        // 풍속 보정
        let windFactor = min(weather.windSpeed / 10.0, 2.0)
        
        // 강수량 보정
        let rainFactor = max(0.1, 1 - weather.precipitation / 50.0)
        
        // KFS 지수 계산
        let kfsScore = (100 - effectiveHumidity) * windFactor * rainFactor
        return min(max(kfsScore, 0), 100)
    }
    
    func calculateHumanActivityRisk(human: HumanActivityData) -> Double {
        // 인구밀도 점수
        let popScore = min(human.populationDensity / 1000.0 * 30, 30)
        
        // 등산로 밀도 점수
        let trailScore = Double(human.hikingTrails) * 15
        
        // 주거지 근접성 점수
        let proximityScore = max(0, 25 - human.residentialProximity * 5)
        
        // 주말 가중치
        let weekendMultiplier = (human.dayOfWeek == 5 || human.dayOfWeek == 6) ? 1.5 : 1.0
        
        let humanRisk = (popScore + trailScore + proximityScore) * weekendMultiplier
        return min(humanRisk, 100)
    }
    
    func calculateForestNDWIRisk(forest: ForestNDWIData) -> Double {
        // 침엽수 비율 점수 (경상북도 특성)
        let coniferScore = forest.coniferRatio * 40
        
        // NDWI 점수 계산 (핵심 기능)
        let ndwiRisk = (1 - forest.ndwiValue) * 30
        let ndwiScore = max(0, min(ndwiRisk, 60))
        
        // 경사도 점수
        let slopeScore = min(forest.slope / 45.0 * 20, 20)
        
        // 고도 점수
        let elevationScore = min(forest.elevation / 1000.0 * 10, 15)
        
        let forestRisk = coniferScore + ndwiScore + slopeScore + elevationScore
        return min(forestRisk, 100)
    }
    
    func calculateIntegratedRisk(weather: SimpleWeatherData, human: HumanActivityData, forest: ForestNDWIData) -> FireRiskCalculationResult {
        // 각 레이어별 위험도 계산
        let kfsRisk = calculateKFSIndex(weather: weather)
        let humanRisk = calculateHumanActivityRisk(human: human)
        let forestRisk = calculateForestNDWIRisk(forest: forest)
        
        // 가중 평균으로 최종 위험도 계산
        let totalRisk = kfsRisk * layerWeights["kfs_index"]! +
                       humanRisk * layerWeights["human_activity"]! +
                       forestRisk * layerWeights["forest_ndwi"]!
        
        return FireRiskCalculationResult(
            totalRisk: totalRisk,
            kfsRisk: kfsRisk,
            humanRisk: humanRisk,
            forestRisk: forestRisk,
            riskLevel: getRiskLevel(totalRisk),
            ndwiValue: forest.ndwiValue
        )
    }
    
    private func getRiskLevel(_ riskScore: Double) -> String {
        switch riskScore {
        case 80...: return "Very High"
        case 60..<80: return "High"
        case 40..<60: return "Moderate"
        case 20..<40: return "Low"
        default: return "Very Low"
        }
    }
}

// MARK: - Updated Fire Risk Area Model
struct FireRiskArea {
    let id = UUID()
    let name: String
    let riskLevel: Int // 1-5 (5 = most dangerous)
    let temperature: Int
    let humidity: Int
    let windSpeed: Double
    let lastUpdated: Date
    
    // 3-Layer 계산 결과
    let calculationResult: FireRiskCalculationResult
    
    // Extended data (기존 호환성 유지)
    let enhancedData: EnhancedFireRiskArea
}

class FireRiskViewModel: ObservableObject {
    @Published var topRiskAreas: [FireRiskArea] = []
    private let calculator = FireRiskCalculator()
    
    init() {
        loadCalculatedData()
    }
    
    private func loadCalculatedData() {
        let regions = [
            ("Uljin-gun Buk-myeon", 36.9, 129.4, "coastal_pine"),      // Coastal pine forest
            ("Andong-si Imha-myeon", 36.5, 128.8, "inland_mixed"),     // Inland mixed forest
            ("Bonghwa-gun Chunyang-myeon", 36.8, 128.9, "mountain_pine"),    // Mountain pine forest
            ("Yeongdeok-gun Yeonghae-myeon", 36.4, 129.4, "coastal_mixed"),    // Coastal mixed forest
            ("Cheongsong-gun Jinbo-myeon", 36.3, 129.1, "highland_oak")      // Highland oak forest
        ]
        
        var calculatedAreas: [FireRiskArea] = []
        
        for (regionName, lat, lon, type) in regions {
            let (weather, human, forest) = generateRegionSpecificData(for: type, regionName: regionName)
            
            // 3-Layer risk calculation
            let result = calculator.calculateIntegratedRisk(
                weather: weather,
                human: human,
                forest: forest
            )
            
            // Convert risk to 1-5 scale
            let riskLevel = Int(min(max(result.totalRisk / 20, 1), 5))
            
            let area = FireRiskArea(
                name: regionName,
                riskLevel: riskLevel,
                temperature: Int(weather.temperature),
                humidity: Int(weather.humidity),
                windSpeed: weather.windSpeed,
                lastUpdated: Date(),
                calculationResult: result,
                enhancedData: createEnhancedData(
                    name: regionName,
                    weather: weather,
                    forest: forest,
                    lat: lat,
                    lon: lon
                )
            )
            
            calculatedAreas.append(area)
        }
        
        // Sort by risk level
        topRiskAreas = calculatedAreas.sorted { $0.calculationResult.totalRisk > $1.calculationResult.totalRisk }
    }
    
    private func generateRegionSpecificData(for type: String, regionName: String) -> (SimpleWeatherData, HumanActivityData, ForestNDWIData) {
        switch type {
        case "coastal_pine": // Uljin-gun Buk-myeon - Highest risk
            return (
                SimpleWeatherData(
                    temperature: 34.0,      // Very high temperature
                    humidity: 25.0,         // Very low humidity
                    windSpeed: 12.5,        // Strong wind
                    precipitation: 0.0      // No precipitation
                ),
                HumanActivityData(
                    populationDensity: 1800,    // High population density
                    hikingTrails: 7,            // Many hiking trails
                    residentialProximity: 0.8,  // Very close to residential area
                    dayOfWeek: 6                // Sunday (weekend)
                ),
                ForestNDWIData(
                    coniferRatio: 0.92,     // Very high conifer ratio
                    ndwiValue: -0.28,       // Very dry
                    slope: 38.0,            // Steep slope
                    elevation: 850.0        // High elevation
                )
            )
            
        case "mountain_pine": // Bonghwa-gun Chunyang-myeon - High risk
            return (
                SimpleWeatherData(
                    temperature: 31.0,
                    humidity: 35.0,
                    windSpeed: 9.2,
                    precipitation: 1.5
                ),
                HumanActivityData(
                    populationDensity: 450,     // Low population density
                    hikingTrails: 5,
                    residentialProximity: 3.2,
                    dayOfWeek: 5                // Saturday
                ),
                ForestNDWIData(
                    coniferRatio: 0.88,
                    ndwiValue: -0.15,           // Dry
                    slope: 32.0,
                    elevation: 1150.0           // Very high elevation
                )
            )
            
        case "inland_mixed": // Andong-si Imha-myeon - Moderate risk
            return (
                SimpleWeatherData(
                    temperature: 28.0,
                    humidity: 45.0,
                    windSpeed: 6.8,
                    precipitation: 3.2
                ),
                HumanActivityData(
                    populationDensity: 1200,    // Medium population density
                    hikingTrails: 4,
                    residentialProximity: 1.5,
                    dayOfWeek: 2                // Tuesday (weekday)
                ),
                ForestNDWIData(
                    coniferRatio: 0.65,         // Mixed forest
                    ndwiValue: 0.08,            // Slightly moist
                    slope: 18.0,                // Gentle slope
                    elevation: 320.0
                )
            )
            
        case "coastal_mixed": // Yeongdeok-gun Yeonghae-myeon - Low risk
            return (
                SimpleWeatherData(
                    temperature: 26.0,
                    humidity: 62.0,             // High humidity (coastal)
                    windSpeed: 4.5,
                    precipitation: 8.7          // High precipitation
                ),
                HumanActivityData(
                    populationDensity: 680,
                    hikingTrails: 2,            // Few hiking trails
                    residentialProximity: 4.8,  // Far from residential area
                    dayOfWeek: 1                // Monday
                ),
                ForestNDWIData(
                    coniferRatio: 0.45,         // Low conifer ratio
                    ndwiValue: 0.25,            // Sufficient moisture
                    slope: 12.0,                // Nearly flat
                    elevation: 180.0            // Low elevation
                )
            )
            
        case "highland_oak": // Cheongsong-gun Jinbo-myeon - Very low risk
            return (
                SimpleWeatherData(
                    temperature: 23.0,          // Low temperature
                    humidity: 75.0,             // Very high humidity
                    windSpeed: 3.2,             // Weak wind
                    precipitation: 12.4         // Very high precipitation
                ),
                HumanActivityData(
                    populationDensity: 280,     // Very low population density
                    hikingTrails: 1,            // Almost no hiking trails
                    residentialProximity: 8.5,  // Very far from residential area
                    dayOfWeek: 3                // Wednesday
                ),
                ForestNDWIData(
                    coniferRatio: 0.35,         // Deciduous forest dominant
                    ndwiValue: 0.42,            // Very sufficient moisture
                    slope: 8.0,                 // Very gentle
                    elevation: 420.0
                )
            )
            
        default:
            // Default values (not used)
            return (
                SimpleWeatherData(temperature: 25.0, humidity: 50.0, windSpeed: 5.0, precipitation: 5.0),
                HumanActivityData(populationDensity: 500, hikingTrails: 3, residentialProximity: 3.0, dayOfWeek: 1),
                ForestNDWIData(coniferRatio: 0.7, ndwiValue: 0.0, slope: 20.0, elevation: 500.0)
            )
        }
    }
    
    private func createEnhancedData(name: String, weather: SimpleWeatherData, forest: ForestNDWIData, lat: Double, lon: Double) -> EnhancedFireRiskArea {
        // Create zombie fire history for high-risk areas
        var fireHistory: [FireHistory] = []
        
        // Add zombie fire spots for specific regions
        if name.contains("Uljin-gun") {
            // Uljin - Recent major fire with incomplete suppression
            fireHistory.append(FireHistory(
                fireDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
                burnedArea: 3.8,
                suppressionDate: nil, // Not fully extinguished - zombie fire risk!
                fireIntensity: .extreme,
                location: FireLocation(latitude: lat, longitude: lon, radius: 0.8)
            ))
            fireHistory.append(FireHistory(
                fireDate: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
                burnedArea: 1.2,
                suppressionDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()),
                fireIntensity: .high,
                location: FireLocation(latitude: lat + 0.01, longitude: lon + 0.01, radius: 0.3)
            ))
        } else if name.contains("Bonghwa-gun") {
            // Bonghwa - Recent fire with delayed suppression
            fireHistory.append(FireHistory(
                fireDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
                burnedArea: 2.1,
                suppressionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
                fireIntensity: .high,
                location: FireLocation(latitude: lat, longitude: lon, radius: 0.5)
            ))
        } else if name.contains("Andong-si") {
            // Andong - Small controlled fire
            fireHistory.append(FireHistory(
                fireDate: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
                burnedArea: 0.8,
                suppressionDate: Calendar.current.date(byAdding: .day, value: -43, to: Date()),
                fireIntensity: .moderate,
                location: FireLocation(latitude: lat, longitude: lon, radius: 0.2)
            ))
        }
        // Yeongdeok and Cheongsong have no recent fire history (safer areas)
        
        // Calculate soil moisture based on NDWI and fire history
        let baseMoisture = (forest.ndwiValue + 1) * 15 // NDWI-based soil moisture
        let deepMoisture = (forest.ndwiValue + 1) * 12
        
        // Reduce soil moisture for areas with recent fires
        let moistureReduction = fireHistory.isEmpty ? 0.0 : Double(fireHistory.count * 3)
        let adjustedMoisture = max(5.0, baseMoisture - moistureReduction)
        let adjustedDeepMoisture = max(3.0, deepMoisture - moistureReduction)
        
        // Increase organic matter for areas with fire history (ash and debris)
        let baseOrganicMatter = 12.0
        let organicMatterIncrease = fireHistory.isEmpty ? 0.0 : Double(fireHistory.count * 4)
        let adjustedOrganicMatter = min(25.0, baseOrganicMatter + organicMatterIncrease)
        
        return EnhancedFireRiskArea(
            name: name,
            riskLevel: Int(min(max(calculator.calculateIntegratedRisk(
                weather: weather,
                human: HumanActivityData(populationDensity: 500, hikingTrails: 3, residentialProximity: 2, dayOfWeek: 1),
                forest: forest
            ).totalRisk / 20, 1), 5)),
            weatherData: WeatherData(
                windDirection: .southwest,
                windSpeed: weather.windSpeed,
                temperature: Int(weather.temperature),
                humidity: Int(weather.humidity),
                precipitation: weather.precipitation,
                droughtIndex: max(0, 1 - forest.ndwiValue) // NDWI as drought index
            ),
            geographicData: GeographicData(
                elevation: Int(forest.elevation),
                slope: forest.slope,
                aspect: "Southwest",
                vegetationType: forest.coniferRatio > 0.7 ? .pine : .mixed,
                fuelLoad: forest.coniferRatio * 40
            ),
            soilData: SoilData(
                moistureContent: adjustedMoisture,
                deepSoilMoisture: adjustedDeepMoisture,
                organicMatter: adjustedOrganicMatter,
                soilType: fireHistory.isEmpty ? .loam : .humus, // Fire areas have more humus
                depth: fireHistory.isEmpty ? 8.0 : 12.0, // Deeper organic layer after fires
                recentFireHistory: fireHistory
            ),
            lastUpdated: Date()
        )
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
        default: return "Very Low"
        }
    }
    
    // NDWI-based detailed information
    func getNDWIDescription(_ ndwiValue: Double) -> String {
        switch ndwiValue {
        case 0.3...: return "Sufficient Moisture (Safe)"
        case 0.0..<0.3: return "Moderate Moisture"
        case -0.2..<0.0: return "Dry Condition (Caution)"
        default: return "Very Dry (Dangerous)"
        }
    }
    
    // 3-Layer risk detailed information
    func getDetailedRiskInfo(for area: FireRiskArea) -> String {
        let result = area.calculationResult
        return """
        🔥 Total Risk: \(String(format: "%.1f", result.totalRisk)) points
        📊 KFS Index: \(String(format: "%.1f", result.kfsRisk)) points
        👥 Human Activity: \(String(format: "%.1f", result.humanRisk)) points  
        🌲 Forest+NDWI: \(String(format: "%.1f", result.forestRisk)) points
        💧 NDWI: \(String(format: "%.3f", result.ndwiValue)) (\(getNDWIDescription(result.ndwiValue)))
        """
    }
}


