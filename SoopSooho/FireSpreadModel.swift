//
//  FireSpreadModel.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import Foundation
import SwiftUI

// 화재 이력 데이터 모델
struct FireHistory {
    let fireDate: Date
    let burnedArea: Double // 연소 면적 (ha)
    let suppressionDate: Date? // 진화 완료일 (nil이면 미완료)
    let fireIntensity: FireIntensity
    let location: FireLocation
}

enum FireIntensity: String, CaseIterable {
    case low = "약함"
    case moderate = "보통"
    case high = "강함"
    case extreme = "극강"
    
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
    let radius: Double // 영향 반경 (km)
}

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
    let moistureContent: Double // 표면 토양 수분 함량 (%)
    let deepSoilMoisture: Double // 심층 토양 수분 함량 (20-50cm 깊이, %)
    let organicMatter: Double // 유기물 함량 (%)
    let soilType: SoilType
    let depth: Double // 유기물층 깊이 (cm)
    let recentFireHistory: [FireHistory] // 최근 화재 이력
    
    // ZFRI 계산 (Zombie Fire Risk Index)
    var zfriScore: Double {
        let deepSoilDeficit = 1.0 - (deepSoilMoisture / 100.0) // 심층 토양 건조도
        let organicFactor = min(organicMatter / 100.0, 1.0) // 유기물 함량 비율 (최대 1.0)
        let burnHistoryWeight = calculateBurnHistoryWeight() // 화재 이력 가중치
        
        return deepSoilDeficit * organicFactor * burnHistoryWeight
    }
    
    // ZFRI 점수 기반 위험도 분류
    var zfriRiskLevel: ZombieFireRisk {
        let score = zfriScore
        switch score {
        case 0.8...: return .veryHigh    // 0.8 이상 = 매우 높음
        case 0.6..<0.8: return .high     // 0.6~0.8 = 높음
        case 0.4..<0.6: return .medium   // 0.4~0.6 = 보통
        case 0.2..<0.4: return .low      // 0.2~0.4 = 낮음
        default: return .veryLow         // 0.2 미만 = 매우 낮음
        }
    }
    
    // 최근 화재 이력 가중치 계산
    private func calculateBurnHistoryWeight() -> Double {
        let currentDate = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        
        // 최근 1개월 내 화재 이력 필터링
        let recentFires = recentFireHistory.filter { fire in
            fire.fireDate >= oneMonthAgo
        }
        
        if recentFires.isEmpty {
            return 1.0 // 기본 가중치
        }
        
        // 화재 강도와 진화 여부에 따른 가중치 계산
        var totalWeight = 1.0
        
        for fire in recentFires {
            let intensityMultiplier = fire.fireIntensity.riskMultiplier
            let suppressionFactor = fire.suppressionDate == nil ? 2.0 : 1.3 // 미진화시 더 높은 가중치
            
            // 화재 발생일로부터 경과 시간 (최근일수록 높은 가중치)
            let daysSinceFire = Calendar.current.dateComponents([.day], from: fire.fireDate, to: currentDate).day ?? 30
            let timeFactor = max(0.1, 1.0 - (Double(daysSinceFire) / 30.0)) // 30일에 걸쳐 감소
            
            totalWeight += (intensityMultiplier * suppressionFactor * timeFactor)
        }
        
        return min(totalWeight, 5.0) // 최대 5배까지 가중
    }
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
        // 화재 확산 방향 (바람이 부는 방향) - 화면 좌표계 기준
        switch self {
        case .north: return 90     // 북풍 → 남쪽으로 확산 (아래쪽)
        case .northeast: return 135 // 북동풍 → 남서쪽으로 확산
        case .east: return 180     // 동풍 → 서쪽으로 확산 (왼쪽)
        case .southeast: return 225 // 남동풍 → 북서쪽으로 확산
        case .south: return 270    // 남풍 → 북쪽으로 확산 (위쪽)
        case .southwest: return 315 // 남서풍 → 북동쪽으로 확산
        case .west: return 0       // 서풍 → 동쪽으로 확산 (오른쪽)
        case .northwest: return 45  // 북서풍 → 남동쪽으로 확산
        }
    }
    
    var symbol: String {
        // 화재 확산 방향 화살표
        switch self {
        case .north: return "↓"    // 북풍 → 남쪽(아래)으로 확산
        case .northeast: return "↙" // 북동풍 → 남서쪽으로 확산
        case .east: return "←"     // 동풍 → 서쪽(왼쪽)으로 확산
        case .southeast: return "↖" // 남동풍 → 북서쪽으로 확산
        case .south: return "↑"    // 남풍 → 북쪽(위)으로 확산
        case .southwest: return "↗" // 남서풍 → 북동쪽으로 확산
        case .west: return "→"     // 서풍 → 동쪽(오른쪽)으로 확산
        case .northwest: return "↘" // 북서풍 → 남동쪽으로 확산
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
        let soilRisk = soilData.zfriRiskLevel.riskValue // 계산된 ZFRI 위험도 사용
        
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
