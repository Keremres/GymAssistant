//
//  HomeView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var programService: ProgramService
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @Binding var tabBarName: TabBarName
    @State var start: Bool = false
    
    var body: some View {
        NavigationStack {
            if programService.program != nil {
                ScrollView {
                    GroupBox{
                        if !viewModel.healthCard.isEmpty{
                            HStack{
                                Spacer()
                                VStack{
                                    Text("Step")
                                        .foregroundStyle(.blue)
                                    Text("Goal: 10000 / \(viewModel.healthCard[0])")
                                        .foregroundStyle(.blue)
                                    Text("Calories")
                                        .foregroundStyle(.red)
                                        .padding(.top, CGFloat(5))
                                    Text("Goal: 300 / \(viewModel.healthCard[1])")
                                        .foregroundStyle(.red)
                                }
                                .bold()
                                Spacer(minLength: 0)
                                ZStack{
                                    ProgressCircle(progress: $viewModel.healthCard[0], goal: 10000, color: .blue)
                                    ProgressCircle(progress: $viewModel.healthCard[1], goal: 300, color: .red)
                                        .padding(.all, CGFloat(10))
                                }
                                Spacer()
                            }
                            .frame(height: CGFloat(100))
                        }
                    }label: {
                        HStack{
                            Spacer()
                            Text("\(programService.program?.programName ?? "")  \(programService.program?.programClass ?? "")")
                                .bold()
                                .foregroundStyle(.pink)
                            Spacer()
                        }
                    }
                    LazyVGrid(columns: [GridItem(.flexible())]){
                        ForEach(programService.program!.week) { week in
                            if Date.getCurrentWeekInt(date: week.date) == Date.getCurrentWeekInt(date: Date()) {
                                ForEach(week.day) { day in
                                    NavigationLink(destination: DetailView(dayModel: day)
                                        .navigationBarBackButtonHidden(true)) {
                                            DayGroupBox(dayModel: day, change: true)
                                        }
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    do {
                        try await viewModel.getProgram(user: mainTabViewModel.user)
                        viewModel.fetchTodaySteps()
                        viewModel.fetchTodayCalories()
                    } catch {
                        print("Error refreshing program: \(error.localizedDescription)")
                    }
                }
            } else {
                ScrollView{
                    ContentUnavailableView(label: {
                        Label("No Program Found", systemImage: "tray.fill")
                    }, description: {Text("If you do not have a program, you can create or select a new program.")}, actions: {
                        HStack{
                            BaseNavigationLink(destination: CreateView()
                                .navigationBarBackButtonHidden(true), title: "Create")
                            .padding(.horizontal,5)
                            BaseButton(onTab: {
                                tabBarName = .Search
                            }, title: "Select")
                        }
                    })
                    .padding(.top, UIScreen.main.bounds.height * 0.322)
                }
                .refreshable {
                    do {
                        try await viewModel.getProgram(user: mainTabViewModel.user)
                    } catch {
                        print("Error refreshing program: \(error.localizedDescription)")
                    }
                }
            }
        }.onAppear{
            Task{
                try await viewModel.newWeek(user: mainTabViewModel.user)
            }
            if start == false{
                start.toggle()
                Task{
                    try await viewModel.getProgram(user: mainTabViewModel.user)
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        HomeView(tabBarName: .constant(TabBarName.Home))
            .environmentObject(HomeViewModel())
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
            .environmentObject(ProgramService())
    }
}

