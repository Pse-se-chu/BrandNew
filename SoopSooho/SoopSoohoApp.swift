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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
