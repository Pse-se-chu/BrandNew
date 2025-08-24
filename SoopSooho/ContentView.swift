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
                Text("Soop SooHo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                Text("Check the wildfire risk index of Gyeongsangbuk-do!")
                    .font(.headline)
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 24)
                
                HStack(spacing: 35) {
                    // Realtime Top 5 Risk Areas
                    ZStack {
                        Rectangle()
                            .frame(width: 281, height: 654)
                            .cornerRadius(16)
//                            .foregroundStyle(Color.customGray)
                            .foregroundColor(Color(hex: "E0E9C9"))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Realtime Risk Areas")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                Text("TOP 5")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Last update: \(formatTime(Date()))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // Risk area list
                            ScrollView {
                                LazyVStack(spacing: 16) {
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
                            
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Check live risk levels")
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("and be ready.")
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("@BrandNew")
                                        .font(.caption2)
                                        .fontWeight(.thin)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4.0)
                                }
                                .padding(.trailing, 12)
                                
                                Image("Icon1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80)
                                    .padding(.trailing, 16)
                            }
                        }
                        .frame(width: 281, height: 654)
                    }
                    
                    GoogleMapView()
                        .frame(width: 830, height: 654)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                }.padding(.bottom, 27)
               
            }.padding(.top, 24)
            
            // PopUp
            if showingPopup, let area = selectedArea {
                FireSimulationPopup(area: area, isPresented: $showingPopup)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFireRiskPopup"))) { notification in
            print("🔔 [ContentView] 맵에서 Notification 수신됨!")
            if let area = notification.object as? FireRiskArea {
                print("✅ [ContentView] 맵에서 선택된 지역: \(area.name)")
                selectedArea = area
                showingPopup = true
                print("🎯 [ContentView] 팝업 표시 상태: \(showingPopup)")
            } else {
                print("❌ [ContentView] Notification 객체가 FireRiskArea가 아님: \(String(describing: notification.object))")
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Rank
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
                    
                    // Total risk score display
                    Text("Risk: \(String(format: "%.1f", area.calculationResult.totalRisk)) pts")
                        .font(.caption2)
                        .foregroundColor(viewModel.getRiskLevelColor(area.riskLevel))
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // 3개 레이어 점수만 표시
            HStack(spacing: 12) {
                // Layer 1: KFS
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 2) {
                        Image(systemName: "cloud.sun")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                        Text("KFS")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                    }
                    Text("\(String(format: "%.0f", area.calculationResult.kfsRisk))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                // Layer 2: Human Activity
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 2) {
                        Image(systemName: "person.2")
                            .font(.system(size: 8))
                            .foregroundColor(.purple)
                        Text("Human")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                    }
                    Text("\(String(format: "%.0f", area.calculationResult.humanRisk))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                }
                
                // Layer 3: Forest+NDWI
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 2) {
                        Image(systemName: "leaf")
                            .font(.system(size: 8))
                            .foregroundColor(.green)
                        Text("Forest")
                            .font(.system(size: 8))
                            .fontWeight(.medium)
                    }
                    Text("\(String(format: "%.0f", area.calculationResult.forestRisk))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
            

            
            // 기존 기상 정보
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
        .padding(10)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
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
