//
//  FireRiskModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import Foundation

struct FireRiskArea {
    let id = UUID()
    let name: String
    let riskLevel: Int // 1-5 (5가 가장 위험)
    let temperature: Int
    let humidity: Int
    let windSpeed: Double
    let lastUpdated: Date
    
    // 확장된 데이터 추가
    let enhancedData: EnhancedFireRiskArea
}

class FireRiskViewModel: ObservableObject {
    @Published var topRiskAreas: [FireRiskArea] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // 실제로는 API에서 받아올 데이터
        topRiskAreas = [
            FireRiskArea(
                name: "울진군 북면", 
                riskLevel: 5, 
                temperature: 32, 
                humidity: 15, 
                windSpeed: 8.5, 
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "울진군 북면",
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
                        aspect: "남서",
                        vegetationType: .pine,
                        fuelLoad: 35.2
                    ),
                    soilData: SoilData(
                        moistureContent: 8.5,
                        deepSoilMoisture: 5.2, // 심층 토양이 더 건조
                        organicMatter: 15.2,
                        soilType: .humus,
                        depth: 12.5,
                        zombieFireRisk: .veryHigh,
                        recentFireHistory: [
                            FireHistory(
                                fireDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                                burnedArea: 2.3,
                                suppressionDate: nil, // 미완전 진화
                                fireIntensity: .high,
                                location: FireLocation(latitude: 36.9, longitude: 129.4, radius: 0.5)
                            )
                        ]
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "안동시 임하면", 
                riskLevel: 4, 
                temperature: 29, 
                humidity: 22, 
                windSpeed: 6.2, 
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "안동시 임하면",
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
                        aspect: "서",
                        vegetationType: .mixed,
                        fuelLoad: 28.7
                    ),
                    soilData: SoilData(
                        moistureContent: 12.3,
                        deepSoilMoisture: 8.7,
                        organicMatter: 11.8,
                        soilType: .loam,
                        depth: 8.2,
                        zombieFireRisk: .high,
                        recentFireHistory: [] // 최근 화재 이력 없음
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "봉화군 춘양면", 
                riskLevel: 3, 
                temperature: 26, 
                humidity: 35, 
                windSpeed: 4.8, 
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "봉화군 춘양면",
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
                        aspect: "북서",
                        vegetationType: .mixed,
                        fuelLoad: 28.3
                    ),
                    soilData: SoilData(
                        moistureContent: 18.2,
                        deepSoilMoisture: 14.8,
                        organicMatter: 12.1,
                        soilType: .loam,
                        depth: 8.5,
                        zombieFireRisk: .medium,
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
                name: "영덕군 영해면", 
                riskLevel: 3, 
                temperature: 28, 
                humidity: 28, 
                windSpeed: 5.8, 
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "영덕군 영해면",
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
                        aspect: "동",
                        vegetationType: .oak,
                        fuelLoad: 22.3
                    ),
                    soilData: SoilData(
                        moistureContent: 18.7,
                        deepSoilMoisture: 15.3,
                        organicMatter: 8.9,
                        soilType: .clay,
                        depth: 5.4,
                        zombieFireRisk: .medium,
                        recentFireHistory: [] // 최근 화재 이력 없음
                    ),
                    lastUpdated: Date()
                )
            ),
            FireRiskArea(
                name: "청송군 진보면", 
                riskLevel: 3, 
                temperature: 27, 
                humidity: 31, 
                windSpeed: 4.9, 
                lastUpdated: Date(),
                enhancedData: EnhancedFireRiskArea(
                    name: "청송군 진보면",
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
                        aspect: "남",
                        vegetationType: .shrub,
                        fuelLoad: 18.9
                    ),
                    soilData: SoilData(
                        moistureContent: 22.1,
                        deepSoilMoisture: 19.8,
                        organicMatter: 6.7,
                        soilType: .sand,
                        depth: 4.2,
                        zombieFireRisk: .low,
                        recentFireHistory: [] // 최근 화재 이력 없음
                    ),
                    lastUpdated: Date()
                )
            )
        ]
    }
    
    func getRiskLevelColor(_ level: Int) -> String {
        switch level {
        case 5: return "red"
        case 4: return "orange"
        case 3: return "yellow"
        case 2: return "blue"
        default: return "green"
        }
    }
    
    func getRiskLevelText(_ level: Int) -> String {
        switch level {
        case 5: return "매우 위험"
        case 4: return "위험"
        case 3: return "보통"
        case 2: return "낮음"
        default: return "안전"
        }
    }
}
