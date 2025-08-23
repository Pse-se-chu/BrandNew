//
//  SoopSoohoApp.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import SwiftUI

@main
struct SoopSoohoApp: App {
    // AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showOnboarding: Bool = true

    var body: some Scene {
        WindowGroup {
   
                ContentView()
                    .preferredColorScheme(.light) // 라이트 모드 고정
                    .onAppear {
                        // 가로 모드 고정 - iOS 16+ 호환
                        AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
                    }
            }
        }
    }

