//
//  GymAssistantApp.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct GymAssistantApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager: AuthManager = AppContainer.shared.authManager
    @StateObject var userManager: UserManager = AppContainer.shared.userManager
    @StateObject var programManager: ProgramManager = AppContainer.shared.programManager
    init(){
        let appearanceTab = UITabBarAppearance()
        appearanceTab.configureWithTransparentBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearanceTab
        UITabBar.appearance().standardAppearance = appearanceTab
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(authManager)
        .environmentObject(programManager)
        .environmentObject(userManager)
    }
}
