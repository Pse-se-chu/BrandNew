//
//  OnboardingView.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/24/25.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - Anim states
    @State private var bob: Bool = false           // 마스코트 둥실둥실
    @State private var showTitle: Bool = false     // 타이틀 팝 애니메이션
    @State private var titleScale: CGFloat = 0.6   // 초기 스케일
    var onFinished: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Background (연한 라임색)
            Color(hex: "E6FFA7")
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 0)

                // Mascot (앱 에셋 이름을 프로젝트에 맞게 바꿔주세요: "SoopMascot")
                Image("Icon1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)

                // "Soop SooHo" 텍스트 - 뿅! (팝) 등장
                Text("Soop SooHo")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
                    .scaleEffect(titleScale)
                    .opacity(showTitle ? 1 : 0)
                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                    .onAppear {
                        // 약간의 지연 후 팝 애니메이션
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.62, blendDuration: 0.2)) {
                                showTitle = true
                                titleScale = 1.1
                            }
                            // 오버슈트 후 살짝 되돌아오기
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85).delay(0.12)) {
                                titleScale = 1.0
                            }
                        }
                        // 2초 뒤 자동 전환 (콜백)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            onFinished?()
                        }
                    }

                Spacer(minLength: 32)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

