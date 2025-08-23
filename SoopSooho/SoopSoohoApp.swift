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
            if showOnboarding {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
                ContentView()
            }
        }
    }
}
