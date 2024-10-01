//
//  TabBar.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State var currentTab : TabBarName = .Home
    @StateObject var viewModel: MainTabViewModel
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var programService = ProgramService.shared
    
    init(user: User) {
            _viewModel = StateObject(wrappedValue: MainTabViewModel(user: user))
        }
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)){
            TabView(selection: $currentTab){
                HomeView(tabBarName: $currentTab).tag(TabBarName.Home).ignoresSafeArea(.all)
                SearchView().tag(TabBarName.Search).ignoresSafeArea(.all)
                PersonView().tag(TabBarName.Person).ignoresSafeArea(.all)
            }
            .environmentObject(homeViewModel)
            .environmentObject(viewModel)
            .environmentObject(programService)
            HStack(spacing: 0){
                TabButton(title: TabBarName.Home, image: TabBarImage.Home, selected: $currentTab)
                Spacer(minLength: 0)
                TabButton(title: TabBarName.Search, image: TabBarImage.Search, selected: $currentTab)
                Spacer(minLength: 0)
                TabButton(title: TabBarName.Person, image: TabBarImage.Person, selected: $currentTab)
            }.padding(.vertical,5)
                .padding(.horizontal,UIScreen.main.bounds.width * 0.186)
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabView(user: User.MOCK_USER)
}
