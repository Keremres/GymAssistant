//
//  TabBar.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var programManager: ProgramManager
    @StateObject var viewModel = MainTabViewModel()
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)){
            TabView(selection: $viewModel.currentTab){
                HomeView(tabBarName: $viewModel.currentTab, programManager: programManager, userManager: userManager)
                    .tag(TabBarName.Home)
                    .ignoresSafeArea(.all)
                SearchView(programManager: programManager, userManager: userManager)
                    .tag(TabBarName.Search)
                    .ignoresSafeArea(.all)
                PersonView(authManager: authManager, userManager: userManager, programManager: programManager)
                    .tag(TabBarName.Person)
                    .ignoresSafeArea(.all)
            }
            tabButton
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let programManager = ProgramManager(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    MainTabView()
        .environmentObject(authManager)
        .environmentObject(userManager)
        .environmentObject(programManager)
}

extension MainTabView {
    
    private var tabButton: some View {
            HStack(spacing: 0){
                TabButton(title: TabBarName.Home, image: TabBarImage.Home, selected: $viewModel.currentTab)
                Spacer(minLength: 0)
                TabButton(title: TabBarName.Search, image: TabBarImage.Search, selected: $viewModel.currentTab)
                Spacer(minLength: 0)
                TabButton(title: TabBarName.Person, image: TabBarImage.Person, selected: $viewModel.currentTab)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            .background(Color.tabBarText.clipShape(Capsule()))
            .frame(width: 250)
    }
}
