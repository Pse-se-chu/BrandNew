//
//  AppDelegate.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 🔑 API Key 등록
        GMSServices.provideAPIKey("AIzaSyD3H89lLViNhROAm1TiiQwBLgkQ95OBAfI")
        return true
    }
}
