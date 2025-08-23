//
//  FireSimulationPopup.swift
//  SoopSooho
//
//  Created by AI Assistant on 8/23/25.
//

import SwiftUI

struct FireSimulationPopup: View {
    let area: FireRiskArea
    @Binding var isPresented: Bool
    @State private var simulationProgress: Double = 0.0
    @State private var isSimulating = false
    @State private var spreadPoints: [SpreadPoint] = []
    @State private var zombieFirePoints: [SpreadPoint] = []
    @State private var selectedTab = 0
    @State private var riskScoreProgress: Double = 0.0 // 위험도 링 애니메이션용
    
    // FireRiskViewModel 인스턴스 생성
    private let viewModel = FireRiskViewModel()
    
    var body: some View {
        ZStack {
            // 배경 오버레이
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // 팝업 컨텐츠
            VStack(spacing: 0) {
                // 헤더
                headerView
                
                Divider()
                
                // 탭 선택
                tabSelectionView
                
                // 컨텐츠
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            currentRiskView
                        } else if selectedTab == 1 {
                            environmentalDataView
                        } else {
                            simulationView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .frame(width: 600, height: 700)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .onAppear {
                // 디버깅: 위험도 계산값 출력
                let weatherRisk = area.enhancedData.calculateWeatherRisk()
                let geographicRisk = area.enhancedData.calculateGeographicRisk()
                let soilRisk = area.enhancedData.soilData.zfriRiskLevel.riskValue
                let overallRisk = area.enhancedData.overallRiskScore
                
                print("=== 위험도 계산 ===")
                print("Weather Risk: \(weatherRisk)")
                print("Geographic Risk: \(geographicRisk)")
                print("Soil Risk: \(soilRisk)")
                print("Overall Risk: \(overallRisk)")
                print("==================")
                
                // 위험도 링 애니메이션 시작 (약간의 지연 후)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        riskScoreProgress = overallRisk
                    }
                }
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(area.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Wildfire Risk Analysis & Spread Simulation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Tab Selection View

    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: getTabIcon(index))
                            Text(getTabTitle(index))
                        }
                        .font(.subheadline)
                        .fontWeight(selectedTab == index ? .semibold : .regular)
                        .foregroundColor(selectedTab == index ? .blue : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "gauge"
        case 1: return "leaf"
        case 2: return "flame"
        default: return "questionmark"
        }
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "Risk Index"
        case 1: return "Environmental Data"
        case 2: return "Spread Simulation"
        default: return ""
        }
    }
    
    // MARK: - Current Risk View

    private var currentRiskView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 종합 위험도
            VStack(alignment: .leading, spacing: 12) {
                Text("종합 위험도 지수")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    // 위험도 게이지
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: riskScoreProgress)
                                .stroke(
                                    viewModel.getRiskLevelColor(area.riskLevel),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.5), value: riskScoreProgress)
                            
                            VStack {
                                Text("\(area.riskLevel)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.getRiskLevelColor(area.riskLevel))
                                Text(String(format: "%.1f%%", area.enhancedData.overallRiskScore * 100))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(viewModel.getRiskLevelText(area.riskLevel))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.getRiskLevelColor(area.riskLevel))
                    }
                    
                    // 기본 기상 정보
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "thermometer")
                                .foregroundColor(.red)
                            Text("온도: \(area.temperature)°C")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "drop")
                                .foregroundColor(.blue)
                            Text("습도: \(area.humidity)%")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "wind")
                                .foregroundColor(.gray)
                            Text("풍속: \(String(format: "%.1f", area.windSpeed))m/s")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.green)
                            Text("풍향: \(area.enhancedData.weatherData.windDirection.rawValue) \(area.enhancedData.weatherData.windDirection.symbol)")
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
//            .background(Color.gray.opacity(0.1))
            .background(Color(hex: "E0E9C9"))
            .cornerRadius(12)
            
            // 위험 요소 분석
            VStack(alignment: .leading, spacing: 12) {
                Text("Risk Factor Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    riskFactorCard("Weather Conditions", value: area.enhancedData.calculateWeatherRisk() * 100, color: .orange)
                    riskFactorCard("Geographic Conditions", value: area.enhancedData.calculateGeographicRisk() * 100, color: .green)
                    riskFactorCard("Soil Conditions", value: area.enhancedData.soilData.zfriRiskLevel.riskValue * 100, color: .brown)
                    riskFactorCard("Drought Index", value: area.enhancedData.weatherData.droughtIndex * 100, color: .red)
                }
            }
        }
    }
    
    private func riskFactorCard(_ title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.0f%%", value))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            ProgressView(value: value / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
    
    // MARK: - Environmental Data View

    private var environmentalDataView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 지형 정보
            VStack(alignment: .leading, spacing: 12) {
                Text("지형 정보")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    environmentDataCard("Elevation", "\(area.enhancedData.geographicData.elevation)m", "mountain.2")
                    environmentDataCard("Slope", String(format: "%.1f°", area.enhancedData.geographicData.slope), "triangle")
                    environmentDataCard("Aspect", area.enhancedData.geographicData.aspect, "location.north")
                    environmentDataCard("Vegetation", area.enhancedData.geographicData.vegetationType.rawValue, "leaf")
                }
            }
            .padding(16)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // 토양 정보 및 좀비불 위험도
            VStack(alignment: .leading, spacing: 12) {
                Text("토양 정보 & 좀비불 위험도")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            environmentDataCard("Surface Soil Moisture", String(format: "%.1f%%", area.enhancedData.soilData.moistureContent), "drop")
                            environmentDataCard("Deep Soil Moisture", String(format: "%.1f%%", area.enhancedData.soilData.deepSoilMoisture), "drop.fill")
                        }
                                
                        VStack(alignment: .leading, spacing: 8) {
                            environmentDataCard("Organic Matter", String(format: "%.1f%%", area.enhancedData.soilData.organicMatter), "leaf.circle")
                            environmentDataCard("Organic Layer Depth", String(format: "%.1fcm", area.enhancedData.soilData.depth), "ruler")
                        }
                    }
                            
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            environmentDataCard("Soil Type", area.enhancedData.soilData.soilType.rawValue, "globe.asia.australia")
                        }
                                
                        VStack(alignment: .leading, spacing: 8) {
                            if !area.enhancedData.soilData.recentFireHistory.isEmpty {
                                environmentDataCard("Recent Fires", "\(area.enhancedData.soilData.recentFireHistory.count)", "flame.fill")
                            } else {
                                environmentDataCard("Recent Fires", "None", "checkmark.circle")
                            }
                        }
                    }
                    
                    // 좀비불 위험도 특별 표시
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Zombie Fire Risk (ZFRI)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(area.enhancedData.soilData.zfriRiskLevel.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(area.enhancedData.soilData.zfriRiskLevel.color)
                                Text("ZFRI: \(String(format: "%.3f", area.enhancedData.soilData.zfriScore))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                                    .frame(width: 60, height: 60)
                                
                                Circle()
                                    .trim(from: 0, to: min(area.enhancedData.soilData.zfriRiskLevel.riskValue, 1.0))
                                    .stroke(
                                        area.enhancedData.soilData.zfriRiskLevel.color,
                                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                    )
                                    .frame(width: 60, height: 60)
                                    .rotationEffect(.degrees(-90))
                                
                                Image(systemName: "flame.circle")
                                    .font(.title3)
                                    .foregroundColor(area.enhancedData.soilData.zfriRiskLevel.color)
                            }
                        }
                        
                        // ZFRI 구성 요소 표시
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ZFRI 구성 요소:")
                                .font(.caption)
                                .fontWeight(.medium)
                            HStack {
                                Text("• 심층토양건조도: \(String(format: "%.2f", 1.0 - (area.enhancedData.soilData.deepSoilMoisture / 100.0)))")
                                    .font(.caption2)
                                Spacer()
                            }
                            HStack {
                                Text("• 유기물함량: \(String(format: "%.1f%%", area.enhancedData.soilData.organicMatter))")
                                    .font(.caption2)
                                Spacer()
                            }
                            if !area.enhancedData.soilData.recentFireHistory.isEmpty {
                                HStack {
                                    Text("• 최근화재이력: \(area.enhancedData.soilData.recentFireHistory.count)건")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(area.enhancedData.soilData.zfriRiskLevel.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color.brown.opacity(0.1))
            .cornerRadius(12)
            
            // 기상 상세 정보
            VStack(alignment: .leading, spacing: 12) {
                Text("기상 상세 정보")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    environmentDataCard("강수량", String(format: "%.1fmm", area.enhancedData.weatherData.precipitation), "cloud.rain")
                    environmentDataCard("가뭄 지수", String(format: "%.1f%%", area.enhancedData.weatherData.droughtIndex * 100), "sun.max")
                    environmentDataCard("연료량", String(format: "%.1fton/ha", area.enhancedData.geographicData.fuelLoad), "tree")
                    environmentDataCard("가연성", String(format: "%.0f%%", area.enhancedData.geographicData.vegetationType.flammability * 100), "flame")
                }
            }
            .padding(16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func environmentDataCard(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.05), radius: 1)
    }
    
    // MARK: - Simulation View

    private var simulationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 시뮬레이션 컨트롤
            HStack {
                Text("산불 확산 시뮬레이션")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    startSimulation()
                }) {
                    HStack {
                        Image(systemName: isSimulating ? "stop.circle" : "play.circle")
                        Text(isSimulating ? "중지" : "시뮬레이션 시작")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isSimulating ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // 시뮬레이션 맵 영역
            ZStack {
                // 배경 지형
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.brown.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 250)
                    .cornerRadius(12)
                
                // 풍향 표시
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("풍향: \(area.enhancedData.weatherData.windDirection.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(area.enhancedData.weatherData.windDirection.symbol)
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(6)
                    }
                    Spacer()
                }
                .padding(12)
                
                if simulationProgress > 0 {
                    // 발화 지점
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .position(x: 150, y: 125)
                    
                    // 일반 산불 확산
                    ForEach(spreadPoints.indices, id: \.self) { index in
                        let point = spreadPoints[index]
                        Circle()
                            .fill(Color.red.opacity(point.intensity))
                            .frame(width: 8 + (point.intensity * 20), height: 8 + (point.intensity * 20))
                            .position(x: point.x, y: point.y)
                            .animation(.easeInOut(duration: 0.5), value: simulationProgress)
                    }
                    
                    // 좀비불 지점
                    ForEach(zombieFirePoints.indices, id: \.self) { index in
                        let point = zombieFirePoints[index]
                        if point.isZombieFire {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.6))
                                    .frame(width: 16, height: 16)
                                Circle()
                                    .stroke(Color.purple, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "flame.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            .position(x: point.x, y: point.y)
                            .animation(.easeInOut(duration: 0.8), value: simulationProgress)
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("시뮬레이션을 시작하세요")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("풍향, 지형, 토양 데이터를 기반으로 확산을 예측합니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // 시뮬레이션 진행 정보
            if simulationProgress > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("확산 진행률")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(simulationProgress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: simulationProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        simulationInfoCard("예상 확산 시간", "\(Int(simulationProgress * 180))분", .orange)
                        simulationInfoCard("영향 면적", String(format: "%.1fha", simulationProgress * 25.5), .red)
                        simulationInfoCard("좀비불 지점", "\(zombieFirePoints.filter { $0.isZombieFire }.count)개소", .purple)
                        simulationInfoCard("진화 난이도", getSuppressionDifficulty(), getSuppressionColor())
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private func simulationInfoCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(6)
    }
    
    private func getSuppressionDifficulty() -> String {
        let difficulty = simulationProgress * area.enhancedData.overallRiskScore
        switch difficulty {
        case 0..<0.2: return "쉬움"
        case 0.2..<0.4: return "보통"
        case 0.4..<0.6: return "어려움"
        case 0.6..<0.8: return "매우 어려움"
        default: return "극도로 어려움"
        }
    }
    
    private func getSuppressionColor() -> Color {
        let difficulty = simulationProgress * area.enhancedData.overallRiskScore
        switch difficulty {
        case 0..<0.2: return .green
        case 0.2..<0.4: return .yellow
        case 0.4..<0.6: return .orange
        case 0.6..<0.8: return .red
        default: return .purple
        }
    }
    
    // MARK: - Simulation Logic

    private func startSimulation() {
        if isSimulating {
            isSimulating = false
        } else {
            isSimulating = true
            simulationProgress = 0.0
            generateSpreadPoints()
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if simulationProgress < 1.0 && isSimulating {
                    simulationProgress += 0.015
                    updateSpreadPoints()
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func generateSpreadPoints() {
        spreadPoints.removeAll()
        zombieFirePoints.removeAll()
        
        let windDirection = area.enhancedData.weatherData.windDirection
        let windSpeed = area.enhancedData.weatherData.windSpeed
        let slope = area.enhancedData.geographicData.slope
        
        // 풍향에 따른 확산 방향 계산
        let windAngle = windDirection.angle * .pi / 180
        
        // 풍속에 따른 확산 강도 (풍속이 클수록 더 멀리, 더 빠르게 확산)
        let windSpeedFactor = min(windSpeed / 5.0, 3.0) // 최대 3배까지 증가
        
        // 일반 확산 지점들 생성
        for i in 0..<12 {
            // 주 확산 방향 (풍향 기준)
            let mainAngle = windAngle
            // 부차적 확산 (풍향에서 ±10도 범위로 더 집중)
            let angleVariation = Double.random(in: -0.175...0.175) // ±10도
            let finalAngle = mainAngle + angleVariation
            
            // 거리 계산 (풍속과 시간에 비례)
            let baseDistance = Double(i) * 12 // 기본 거리
            let windInfluence = baseDistance * windSpeedFactor // 풍속 영향
            let randomVariation = Double.random(in: -8...8) // 랜덤 변화
            let totalDistance = windInfluence + randomVariation
            
            // 경사도 영향 (상향 경사에서는 확산 가속)
            let slopeMultiplier = 1.0 + (slope / 90.0) // 경사도에 비례
            
            let x = 150 + cos(finalAngle) * totalDistance * slopeMultiplier
            let y = 125 + sin(finalAngle) * totalDistance * slopeMultiplier
            
            spreadPoints.append(SpreadPoint(
                x: max(20, min(280, x)),
                y: max(20, min(230, y)),
                intensity: 0.0,
                arrivalTime: Double(i) * (6.0 / windSpeedFactor), // 풍속이 클수록 빨리 도달
                isZombieFire: false
            ))
        }
        
        // 좀비불 지점들 생성 (ZFRI 기반, 산불 확산 지역 내에서 생성)
        let zfriScore = area.enhancedData.soilData.zfriScore
        let zombieCount = Int(min(zfriScore * 6, 4)) // ZFRI 점수에 따라 최대 4개로 조정
        
        // 산불 확산 지역의 중심점들을 기준으로 좀비불 위치 결정
        let fireSpreadCenters = [
            (x: 120.0, y: 100.0), // 주 확산 지역 1
            (x: 180.0, y: 140.0), // 주 확산 지역 2
            (x: 200.0, y: 110.0), // 주 확산 지역 3
            (x: 160.0, y: 170.0)  // 주 확산 지역 4
        ]
        
        for i in 0..<zombieCount {
            let centerIndex = i % fireSpreadCenters.count
            let center = fireSpreadCenters[centerIndex]
            
            // 확산 지역 중심에서 가까운 거리에 좀비불 생성
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = Double.random(in: 15...(40 + zfriScore * 20)) // 더 가까운 거리
            
            let x = center.x + cos(angle) * distance
            let y = center.y + sin(angle) * distance
            
            zombieFirePoints.append(SpreadPoint(
                x: max(20, min(280, x)),
                y: max(20, min(230, y)),
                intensity: 0.0,
                // ZFRI가 높을수록 더 빨리 발생하지만 산불 확산 후에 나타남
                arrivalTime: Double(i) * 15 + max(60, 120 - zfriScore * 40),
                isZombieFire: true
            ))
        }
    }
    
    private func updateSpreadPoints() {
        let currentTime = simulationProgress * 180 // 3분 = 180초
        
        // 일반 확산 지점 업데이트
        for i in spreadPoints.indices {
            if currentTime >= spreadPoints[i].arrivalTime {
                let timeSinceArrival = currentTime - spreadPoints[i].arrivalTime
                spreadPoints[i].intensity = min(1.0, timeSinceArrival / 30.0)
            }
        }
        
        // 좀비불 지점 업데이트
        for i in zombieFirePoints.indices {
            if currentTime >= zombieFirePoints[i].arrivalTime {
                let timeSinceArrival = currentTime - zombieFirePoints[i].arrivalTime
                zombieFirePoints[i].intensity = min(0.8, timeSinceArrival / 45.0)
            }
        }
    }
}

<<<<<<< HEAD
//#Preview {
//    FireSimulationPopup(
//        area: FireRiskArea(
//            name: "울진군 북면", 
//            riskLevel: 5, 
//            temperature: 32, 
//            humidity: 15, 
//            windSpeed: 8.5, 
=======
// #Preview {
//    FireSimulationPopup(
//        area: FireRiskArea(
//            name: "울진군 북면",
//            riskLevel: 5,
//            temperature: 32,
//            humidity: 15,
//            windSpeed: 8.5,
>>>>>>> d137af3f233290b93d31611ebe31d436ce39ccc4
//            lastUpdated: Date(),
//            enhancedData: EnhancedFireRiskArea(
//                name: "울진군 북면",
//                riskLevel: 5,
//                weatherData: WeatherData(
//                    windDirection: .southwest,
//                    windSpeed: 8.5,
//                    temperature: 32,
//                    humidity: 15,
//                    precipitation: 0.0,
//                    droughtIndex: 0.85
//                ),
//                geographicData: GeographicData(
//                    elevation: 450,
//                    slope: 25.0,
//                    aspect: "남서",
//                    vegetationType: .pine,
//                    fuelLoad: 35.2
//                ),
//                soilData: SoilData(
//                    moistureContent: 8.5,
//                    organicMatter: 15.2,
//                    soilType: .humus,
//                    depth: 12.5,
//                    zombieFireRisk: .veryHigh
//                ),
//                lastUpdated: Date()
//            )
//        ),
//        isPresented: .constant(true)
//    )
//}
