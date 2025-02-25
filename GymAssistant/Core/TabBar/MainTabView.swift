//
//  TabBar.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)){
            TabView(selection: $viewModel.currentTab){
                HomeView(tabBarName: $viewModel.currentTab)
                    .tag(TabBarName.Home)
                    .ignoresSafeArea(.all)
                SearchView()
                    .tag(TabBarName.Search)
                    .ignoresSafeArea(.all)
                PersonView()
                    .tag(TabBarName.Person)
                    .ignoresSafeArea(.all)
            }
            tabButton
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppContainer.shared.authManager)
        .environmentObject(AppContainer.shared.userManager)
        .environmentObject(AppContainer.shared.programManager)
}

extension MainTabView {
    
    private var tabButton: some View {
        HStack(spacing: 0){
            TabButton(title: TabBarName.Home, titleText: LocaleKeys.Tab.home.localized, image: TabBarImage.Home, selected: $viewModel.currentTab)
            Spacer(minLength: 0)
            TabButton(title: TabBarName.Search, titleText: LocaleKeys.Tab.search.localized, image: TabBarImage.Search, selected: $viewModel.currentTab)
            Spacer(minLength: 0)
            TabButton(title: TabBarName.Person, titleText: LocaleKeys.Tab.person.localized, image: TabBarImage.Person, selected: $viewModel.currentTab)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 5)
        .background(Color.tabBarText.clipShape(Capsule()))
        .frame(width: 270)
    }
}
