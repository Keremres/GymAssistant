//
//  HomeViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject{
    
    private let healthManager: HealthManager
    private let programManager: ProgramManager
    private let userManager: UserManager
    
    private var cancellables: AnyCancellable?
    
    @Published var steps: [DailyStepModel] = []
    @Published var healthCard: [Int] = []
    
    /// mock steps and healthCard
    @Published var stepsMock: [DailyStepModel] = [DailyStepModel(date: Date.startOfDay, stepCount: 11258)]
    @Published var healthCardMock: [Int] = [ 8527, 256]
    
    @Published var alert: CustomError? = nil
    
    init(healthManager: HealthManager = HealthManager.shared,
         programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager){
        self.healthManager = healthManager
        self.programManager = programManager
        self.userManager = userManager
        Task{
            do{
                try await healthManager.requestHealthKitAccess()
            }catch{
                alert = CustomError.customError(title: "Health Error",
                                                subtitle: "Sorry try again")
            }
        }
        fetchTodaySteps()
        fetchTodaySteps()
        listentoUserInfo()
    }
    
    func fetchDailySteps(startDate: Date){
        healthManager.fetchDailySteps(startDate: startDate){ result in
            self.steps = result
        }
    }
    
    func fetchTodaySteps(){
        healthManager.fetchTodaySteps{ result in
            self.updateHealthCard(type: .steps, with: result)
        }
    }
    
    func fetchTodayCalories(){
        healthManager.fetchTodayCalories{ result in
            self.updateHealthCard(type: .calories, with: result)
        }
    }
    
    func getProgram() {
        Task{
            do{
                guard let userInfo = userManager.userInfo, userInfo.programId != "", userInfo.programId != nil else {
                    throw AppAuthError.userNotFound
                }
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
    
    private func updateHealthCard(type: HealthDataType, with result: Int) {
        healthCard[type.rawValue] = result
    }
    
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

enum HealthDataType: Int {
    case steps = 0
    case calories = 1
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
