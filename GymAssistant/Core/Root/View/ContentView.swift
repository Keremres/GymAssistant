//
//  ContentView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    var body: some View {
        Group{
            if authManager.authInfo == nil{
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.shared.authManager)
}
