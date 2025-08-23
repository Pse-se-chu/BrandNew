//
//  FireSpreadModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import Foundation
import SwiftUI

// 지리 정보 모델
struct GeographicData {
    let elevation: Int // 고도 (m)
    let slope: Double // 경사도 (도)
    let aspect: String // 사면 방향 (북, 남, 동, 서, 북동, 남동, 남서, 북서)
    let vegetationType: VegetationType
    let fuelLoad: Double // 연료량 (ton/ha)
}

enum VegetationType: String, CaseIterable {
    case pine = "소나무림"
    case oak = "참나무림"
    case mixed = "혼효림"
    case grassland = "초지"
    case shrub = "관목림"
    
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

// 토양 데이터 모델
struct SoilData {
    let moistureContent: Double // 토양 수분 함량 (%)
    let organicMatter: Double // 유기물 함량 (%)
    let soilType: SoilType
    let depth: Double // 유기물층 깊이 (cm)
    let zombieFireRisk: ZombieFireRisk
}

enum SoilType: String, CaseIterable {
    case peat = "이탄토"
    case humus = "부식토"
    case clay = "점토"
    case sand = "사질토"
    case loam = "양토"
    
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
    case veryHigh = "매우 높음"
    case high = "높음"
    case medium = "보통"
    case low = "낮음"
    case veryLow = "매우 낮음"
    
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

// 기상 데이터 모델
struct WeatherData {
    let windDirection: WindDirection
    let windSpeed: Double
    let temperature: Int
    let humidity: Int
    let precipitation: Double // 강수량 (mm)
    let droughtIndex: Double // 가뭄 지수 (0-1)
}

enum WindDirection: String, CaseIterable {
    case north = "북"
    case northeast = "북동"
    case east = "동"
    case southeast = "남동"
    case south = "남"
    case southwest = "남서"
    case west = "서"
    case northwest = "북서"
    
    var angle: Double {
        switch self {
        case .north: return 0
        case .northeast: return 45
        case .east: return 90
        case .southeast: return 135
        case .south: return 180
        case .southwest: return 225
        case .west: return 270
        case .northwest: return 315
        }
    }
    
    var symbol: String {
        switch self {
        case .north: return "↑"
        case .northeast: return "↗"
        case .east: return "→"
        case .southeast: return "↘"
        case .south: return "↓"
        case .southwest: return "↙"
        case .west: return "←"
        case .northwest: return "↖"
        }
    }
}

// 확산 예측 포인트
struct SpreadPoint {
    let id = UUID()
    var x: Double
    var y: Double
    var intensity: Double // 화재 강도 (0-1)
    var arrivalTime: Double // 도달 시간 (분)
    var isZombieFire: Bool // 좀비불 여부
}

// 확장된 산불 위험 지역 모델
struct EnhancedFireRiskArea {
    let id = UUID()
    let name: String
    let riskLevel: Int
    let weatherData: WeatherData
    let geographicData: GeographicData
    let soilData: SoilData
    let lastUpdated: Date
    
    // 종합 위험도 계산
    var overallRiskScore: Double {
        let weatherRisk = calculateWeatherRisk()
        let geographicRisk = calculateGeographicRisk()
        let soilRisk = soilData.zombieFireRisk.riskValue
        
        return (weatherRisk * 0.4 + geographicRisk * 0.4 + soilRisk * 0.2)
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

// 시뮬레이션 결과 모델
struct SimulationResult {
    let spreadPoints: [SpreadPoint]
    let affectedArea: Double // 영향 면적 (ha)
    let maxSpreadDistance: Double // 최대 확산 거리 (m)
    let zombieFireLocations: [SpreadPoint]
    let estimatedDuration: Int // 예상 지속 시간 (시간)
    let suppressionDifficulty: SuppressionDifficulty
}

enum SuppressionDifficulty: String, CaseIterable {
    case veryEasy = "매우 쉬움"
    case easy = "쉬움"
    case moderate = "보통"
    case difficult = "어려움"
    case veryDifficult = "매우 어려움"
    
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
