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
}

class FireRiskViewModel: ObservableObject {
    @Published var topRiskAreas: [FireRiskArea] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // 실제로는 API에서 받아올 데이터
        topRiskAreas = [
            FireRiskArea(name: "울진군 북면", riskLevel: 5, temperature: 32, humidity: 15, windSpeed: 8.5, lastUpdated: Date()),
            FireRiskArea(name: "안동시 임하면", riskLevel: 4, temperature: 29, humidity: 22, windSpeed: 6.2, lastUpdated: Date()),
            FireRiskArea(name: "봉화군 춘양면", riskLevel: 4, temperature: 31, humidity: 18, windSpeed: 7.1, lastUpdated: Date()),
            FireRiskArea(name: "영덕군 영해면", riskLevel: 3, temperature: 28, humidity: 28, windSpeed: 5.8, lastUpdated: Date()),
            FireRiskArea(name: "청송군 진보면", riskLevel: 3, temperature: 27, humidity: 31, windSpeed: 4.9, lastUpdated: Date())
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
