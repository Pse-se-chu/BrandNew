//
//  AppDelegate.swift
//  SoopSooho
//
//  Created by Hwnag Seyeon on 8/23/25.
//

import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.landscape
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 🔑 API Key 등록
        GMSServices.provideAPIKey("AIzaSyD3H89lLViNhROAm1TiiQwBLgkQ95OBAfI")
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
