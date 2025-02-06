//
//  HomeViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import Foundation
import Combine
import SwiftUI
import WidgetKit

@MainActor
final class HomeViewModel: ObservableObject{

    private let healthManager: HealthProtocol
    private let programManager: ProgramManager
    private let userManager: UserManager
    
    private var cancellables: AnyCancellable?
    private var cancellablesTimer: AnyCancellable?
    
    @AppStorage("goal", store: UserDefaults(suiteName: "group.com.keremresnenli.GymAssistant")) private(set) var goal: Data = Data()
    @Published private(set) var steps: [DailyStepModel] = []
    @Published private(set) var goals: Goal = .init(stepsGoal: 0, caloriesGoal: 0)
    @Published private(set) var goalsState: Goal = .init(stepsGoal: 0, caloriesGoal: 0)
    
    @Published var showSheet: Bool = false
    @Published var alert: CustomError? = nil
    
    init(healthManager: HealthProtocol = AppContainer.shared.healthManager,
         programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager){
        self.healthManager = healthManager
        self.programManager = programManager
        self.userManager = userManager
        Task {
            do{
                try await healthManager.requestHealthKitAccess()
            } catch {
                alert = CustomError.customError(title: "Health Error",
                                                subtitle: "Sorry try again")
            }
        }
        setupGoals()
        fetchTodaySteps()
        fetchTodayCalories()
        WidgetCenter.shared.reloadAllTimelines()
        listentoUserInfo()
        subscribeToTimer()
    }
    
    func fetchDailySteps(startDate: Date){
        healthManager.fetchDailySteps(startDate: startDate){ result in
            DispatchQueue.main.async{
                self.steps = result
            }
        }
    }
    
    func fetchTodaySteps(){
        healthManager.fetchTodaySteps{ result in
            DispatchQueue.main.async{
                self.goalsState.stepsGoal = result
            }
        }
    }
    
    func fetchTodayCalories(){
        healthManager.fetchTodayCalories{ result in
            DispatchQueue.main.async{
                self.goalsState.caloriesGoal = result
            }
        }
    }
    
    func getProgram() {
        Task{
            do{
                guard let userInfo = userManager.userInfo else {
                    throw AppAuthError.userNotFound
                }
                guard userInfo.programId != "", userInfo.programId != nil else { return }
                try await programManager.getProgram(userInfo: userInfo)
            } catch {
                handleError(error,
                            title: HomeAlert.notBeFetched.title,
                            subtitle: HomeAlert.notBeFetched.subtitle)
            }
        }
    }
    
    func newWeek() {
        Task{
            do{
                guard let userInfo = userManager.userInfo else { return }
                try await programManager.newWeek(userInfo: userInfo)
            } catch {
                handleError(error, title: "New Week Error", subtitle: "Try again")
            }
        }
    }
    
    private func listentoUserInfo(){
        cancellables = userManager.$userInfo
            .sink { [weak self] userInfo in
                if userInfo != nil {
                    self?.getProgram()
                    self?.newWeek()
                    self?.cancellables?.cancel()
                    self?.cancellables = nil
                }
            }
    }
    
    private func subscribeToTimer() {
        cancellablesTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchTodaySteps()
                self?.fetchTodayCalories()
                WidgetCenter.shared.reloadAllTimelines()
            }
    }
    
    func setupGoals() {
        if let goals = try? JSONDecoder().decode(Goal.self, from: self.goal) {
            self.goals.stepsGoal = goals.stepsGoal
            self.goals.caloriesGoal = goals.caloriesGoal
        }
    }
    
    @MainActor
    private func handleError(_ error: Error, title: String = "Error", subtitle: String = "Try again") {
        switch error {
        case let error as CustomError:
            alert = error
        case let error as AppAuthError:
            alert = .authError(appAuthError: error)
        default:
            alert = CustomError.customError(title: title,
                                            subtitle: subtitle)
        }
    }
}

enum HomeAlert{
    case notBeFetched
    
    var title: String{
        switch self{
        case .notBeFetched:
            "Error"
        }
    }
    
    var subtitle: String{
        switch self{
        case .notBeFetched:
            "Program could not be fetched"
        }
    }
}
