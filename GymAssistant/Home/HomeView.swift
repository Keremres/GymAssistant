//
//  HomeView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var programManager: ProgramManager
    @StateObject private var viewModel: HomeViewModel
    @Binding var tabBarName: TabBarName
    
    init(tabBarName: Binding<TabBarName>,
         healthManager: HealthProtocol = AppContainer.shared.healthManager,
         programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(healthManager: healthManager, programManager: programManager, userManager: userManager))
        _tabBarName = tabBarName
    }
    
    var body: some View {
        NavigationStack {
            if programManager.program != nil {
                ScrollView{
                    healthCard
                        .background(Color.tabBarText.opacity(0.0001).ignoresSafeArea(.all))
                        .onTapGesture {
                            viewModel.showSheet.toggle()
                        }
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
        .sheet(isPresented: $viewModel.showSheet) {
            GoalSettingView()
                .presentationDetents([.fraction(0.3)])
        }
        .onAppear{
            viewModel.newWeek()
        }
        .onChange(of: viewModel.goal) {
            viewModel.setupGoals()
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
            HStack{
                Spacer()
                VStack{
                    Text(LocaleKeys.Home.step.localized)
                        .foregroundStyle(.blue)
                    Text(viewModel.goals.stepsGoal != 0 ? "\(LocaleKeys.Home.goal.localized): \(viewModel.goals.stepsGoal) / \(viewModel.goalsState.stepsGoal)" : LocaleKeys.Home.stepText.localized)
                        .foregroundStyle(.blue)
                    Text(LocaleKeys.Home.calories.localized)
                        .foregroundStyle(.red)
                        .padding(.top, CGFloat(5))
                    Text(viewModel.goals.caloriesGoal != 0 ? "\(LocaleKeys.Home.goal.localized): \(viewModel.goals.caloriesGoal) / \(viewModel.goalsState.caloriesGoal)" : LocaleKeys.Home.caloriesText.localized)
                        .foregroundStyle(.red)
                }
                .bold()
                Spacer(minLength: 0)
                ZStack{
                    ProgressCircle(progress: viewModel.goalsState.stepsGoal,
                                   goal: viewModel.goals.stepsGoal,
                                   color: .blue)
                    ProgressCircle(progress: viewModel.goalsState.caloriesGoal,
                                   goal: viewModel.goals.caloriesGoal,
                                   color: .red)
                    .padding(.all, CGFloat(10))
                }
                Spacer()
            }
            .frame(height: CGFloat(100))
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
            Label(LocaleKeys.Home.emptyHome.localized, systemImage: SystemImage.trayFill)
        }, description: {Text(LocaleKeys.Home.emptyHomeText.localized)}, actions: {
            HStack{
                BaseNavigationLink(destination: CreateView()
                    .navigationBarBackButtonHidden(true), title: LocaleKeys.Home.create.localized)
                .padding(.horizontal,5)
                BaseButton(onTab: {
                    withAnimation(.spring()){
                        tabBarName = .Search
                    }
                }, title: LocaleKeys.Home.select.localized)
            }
        })
        .padding(.top, UIScreen.main.bounds.height * 0.322)
    }
}
