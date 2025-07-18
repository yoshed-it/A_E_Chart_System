//
//  A_E_ChartingApp.swift
//  A_E_Charting
//
//  Created by Yosh Nebe on 6/27/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct PluckrApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authService = AuthService()

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        if authService.isAuthenticated {
          ProviderHomeView()
        } else {
          LoginView()
        }
      }
    }
  }
}
