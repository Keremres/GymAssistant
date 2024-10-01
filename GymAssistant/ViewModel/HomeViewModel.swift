//
//  HomeViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import Foundation
import Firebase
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject{
    
    private let healthManager = HealthManager.shared
    private let programService = ProgramService.shared
    
    @Published var steps: [DailyStepModel] = []
    @Published var healthCard: [Int] = []
    
    @Published var stepsMock: [DailyStepModel] = [DailyStepModel(date: Date.startOfDay, stepCount: 11258)]
    @Published var healthCardMock: [Int] = [ 8527, 256]
    
    @Published var alert: CustomError? = nil

    init(){
        Task{
            do{
                try await healthManager.requestHealthKitAccess()
            }catch{
                alert = CustomError.customError(title: "Health Error", subtitle: "Sorry try again")
            }
        }
        healthManager.fetchTodaySteps{ result in
                self.healthCard[0] = result
        }
        healthManager.fetchTodayCalories{ result in
                self.healthCard[1] = result
        }
    }
    func fetchDailySteps(startDate: Date){
        healthManager.fetchDailySteps(startDate: startDate){ result in
                self.steps = result
        }
    }
    func fetchTodaySteps(){
        healthManager.fetchTodaySteps{ result in
                self.healthCard[0] = result
        }
    }
    func fetchTodayCalories(){
        healthManager.fetchTodayCalories{ result in
                self.healthCard[1] = result
        }
    }
    
    func getProgram(user: User) async throws {
        do{
            try await programService.getProgram(user: user)
        }catch {
            alert = CustomError.customError(title: HomeAlert.notBeFetched.title, subtitle: HomeAlert.notBeFetched.subtitle)
        }
    }
    
    func newWeek(user: User) async throws {
        try await programService.newWeek(user: user)
    }
    
    func saveDay(user: User, dayModel: DayModel) async throws {
        try await programService.saveDay(user: user, dayModel: dayModel)
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
