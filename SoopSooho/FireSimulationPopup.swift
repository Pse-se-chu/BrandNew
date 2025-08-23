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
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(area.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("산불 위험도 분석 및 확산 시뮬레이션")
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
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 현재 위험도 지수
                        VStack(alignment: .leading, spacing: 12) {
                            Text("현재 위험도 지수")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 16) {
                                // 위험도 게이지
                                VStack {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                            .frame(width: 80, height: 80)
                                        
                                        Circle()
                                            .trim(from: 0, to: CGFloat(area.riskLevel) / 5.0)
                                            .stroke(
                                                Color(getRiskColor(area.riskLevel)),
                                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                            )
                                            .frame(width: 80, height: 80)
                                            .rotationEffect(.degrees(-90))
                                        
                                        Text("\(area.riskLevel)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(getRiskColor(area.riskLevel)))
                                    }
                                    
                                    Text(getRiskLevelText(area.riskLevel))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(getRiskColor(area.riskLevel)))
                                }
                                
                                // 상세 정보
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
                                        Image(systemName: "clock")
                                            .foregroundColor(.gray)
                                        Text("업데이트: \(formatTime(area.lastUpdated))")
                                            .font(.subheadline)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // 산불 확산 시뮬레이션
                        VStack(alignment: .leading, spacing: 12) {
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
                                Rectangle()
                                    .fill(Color.green.opacity(0.3))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                                
                                if isSimulating {
                                    // 산불 확산 애니메이션
                                    ForEach(0..<3, id: \.self) { index in
                                        Circle()
                                            .fill(Color.red.opacity(0.6))
                                            .frame(width: 20 + (simulationProgress * 60), 
                                                   height: 20 + (simulationProgress * 60))
                                            .offset(
                                                x: CGFloat(index - 1) * 40,
                                                y: CGFloat(index % 2 == 0 ? -20 : 20)
                                            )
                                            .animation(.easeInOut(duration: 0.5), value: simulationProgress)
                                    }
                                } else {
                                    VStack {
                                        Image(systemName: "map")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("시뮬레이션을 시작하세요")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            if isSimulating {
                                VStack(alignment: .leading, spacing: 8) {
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
                                    
                                    Text("예상 확산 시간: \(Int(simulationProgress * 120))분")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .frame(width: 500, height: 600)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
        }
    }
    
    private func startSimulation() {
        if isSimulating {
            isSimulating = false
        } else {
            isSimulating = true
            simulationProgress = 0.0
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if simulationProgress < 1.0 && isSimulating {
                    simulationProgress += 0.02
                } else {
                    timer.invalidate()
                    if simulationProgress >= 1.0 {
                        // 시뮬레이션 완료 시 isSimulating을 false로 하지 않고 그대로 유지
                        // simulationProgress는 1.0으로 유지되어 마지막 화면이 보임
                    }
                }
            }
        }
    }
    
    private func getRiskColor(_ level: Int) -> String {
        switch level {
        case 5: return "red"
        case 4: return "orange"
        case 3: return "yellow"
        case 2: return "blue"
        default: return "green"
        }
    }
    
    private func getRiskLevelText(_ level: Int) -> String {
        switch level {
        case 5: return "매우 위험"
        case 4: return "위험"
        case 3: return "보통"
        case 2: return "낮음"
        default: return "안전"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    FireSimulationPopup(
        area: FireRiskArea(name: "울진군 북면", riskLevel: 5, temperature: 32, humidity: 15, windSpeed: 8.5, lastUpdated: Date()),
        isPresented: .constant(true)
    )
}
