//
//  HomeView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var programManager: ProgramManager
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @Binding var tabBarName: TabBarName
    
    var body: some View {
        NavigationStack {
            if programManager.program != nil {
                ScrollView{
                    healthCard
                    weekDays
                }
                .refreshable {
                    viewModel.getProgram()
                    viewModel.fetchTodaySteps()
                    viewModel.fetchTodayCalories()
                }
            } else {
                ScrollView{
                    emptyProgram
                }
                .refreshable {
                    viewModel.getProgram()
                }
            }
        }
        .showAlert(alert: $viewModel.alert)
        .onAppear{
            viewModel.newWeek()
        }
    }
}

#Preview {
    NavigationStack{
        HomeView(tabBarName: .constant(.Home))
            .environmentObject(AppContainer.shared.programManager)
    }
}

extension HomeView{
    
    private var healthCard: some View{
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
                        ProgressCircle(progress: $viewModel.healthCard[0],
                                       goal: 10000,
                                       color: .blue)
                        ProgressCircle(progress: $viewModel.healthCard[1],
                                       goal: 300,
                                       color: .red)
                        .padding(.all, CGFloat(10))
                    }
                    Spacer()
                }
                .frame(height: CGFloat(100))
            }
        }label: {
            HStack{
                Spacer()
                Text("\(programManager.program?.programName ?? "")  \(programManager.program?.programClass ?? "")")
                    .bold()
                    .foregroundStyle(.pink)
                Spacer()
            }
        }
    }
    
    private var weekDays: some View {
        LazyVGrid(columns: [GridItem(.flexible())]){
            ForEach(programManager.program!.week) { week in
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
    
    private var emptyProgram: some View {
        ContentUnavailableView(label: {
            Label("No Program Found", systemImage: SystemImage.trayFill)
        }, description: {Text("If you do not have a program, you can create or select a new program.")}, actions: {
            HStack{
                BaseNavigationLink(destination: CreateView()
                    .navigationBarBackButtonHidden(true), title: "Create")
                .padding(.horizontal,5)
                BaseButton(onTab: {
                    withAnimation(.spring()){
                        tabBarName = .Search
                    }
                }, title: "Select")
            }
        })
        .padding(.top, UIScreen.main.bounds.height * 0.322)
    }
}
