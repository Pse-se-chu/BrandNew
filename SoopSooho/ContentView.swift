//
//  ContentView.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FireRiskViewModel()
    @State private var showingPopup = false
    @State private var selectedArea: FireRiskArea?
    
    var body: some View {
        ZStack {
            VStack {
                Text("숲 수호")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                Text("경상북도의 산불 예상 지수를 확인하세요!")
                    .font(.headline)
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 24)
                
                HStack(spacing: 35){
                    // 실시간 산불 위험 지역 TOP5
                    ZStack{
                        Rectangle()
                            .frame(width: 281, height: 654)
                            .cornerRadius(16)
                            .foregroundStyle(Color.customGray)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // 헤더
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                   
                                    Text("실시간 위험 지역")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                Text("TOP 5")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("마지막 업데이트: \(formatTime(Date()))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // 위험 지역 리스트
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(Array(viewModel.topRiskAreas.enumerated()), id: \.element.id) { index, area in
                                        FireRiskCard(
                                            area: area, 
                                            rank: index + 1, 
                                            viewModel: viewModel,
                                            onTap: {
                                                selectedArea = area
                                                showingPopup = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 16)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .frame(width: 281, height: 654)
                    }
                    
                    GoogleMapView()
                        .frame(width: 830, height: 654)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                } .padding(.bottom, 27)
               
            }.padding(.top, 24)
            
            // 팝업
            if showingPopup, let area = selectedArea {
                FireSimulationPopup(area: area, isPresented: $showingPopup)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct FireRiskCard: View {
    let area: FireRiskArea
    let rank: Int
    let viewModel: FireRiskViewModel
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // 순위
                ZStack {
                    Circle()
                        .fill(getRankColor())
                        .frame(width: 20, height: 20)
                    Text("\(rank)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(area.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                }
                
                Spacer()
            }
            
            // 상세 정보
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "thermometer")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text("\(area.temperature)°C")
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "drop")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("\(area.humidity)%")
                            .font(.caption2)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "wind")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(String(format: "%.1f", area.windSpeed))m/s")
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(formatTime(area.lastUpdated))
                            .font(.caption2)
                    }
                    
                    Spacer()
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color.white.opacity(0.9))
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
    
    private func getRankColor() -> Color {
        switch rank {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .gray
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
