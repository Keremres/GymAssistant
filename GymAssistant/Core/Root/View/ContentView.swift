//
//  ContentView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.07.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var programManager: ProgramManager
    @StateObject var userManager: UserManager
    
    init(authManager: AuthManager){
        _userManager = StateObject(wrappedValue: UserManager(service: FirebaseUserService(),
                                                             authManager: authManager))
    }
    
    var body: some View {
        Group{
            if authManager.authInfo == nil{
                LoginView(authManager: authManager)
            } else {
                MainTabView()
            }
        }
        .environmentObject(userManager)
        .environmentObject(authManager)
        .environmentObject(programManager)
    }
}

#Preview {
    let programManager = ProgramManager(service: FirebaseProgramService())
    let authManager = AuthManager(service: FirebaseAuthService())
    ContentView(authManager: authManager)
        .environmentObject(authManager)
        .environmentObject(programManager)
    
}
