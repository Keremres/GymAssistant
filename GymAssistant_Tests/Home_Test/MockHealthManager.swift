//
//  MockHealthManager.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.12.2024.
//

import Foundation

final class MockHealthManager: HealthProtocol {
    
    var shouldFailRequest: Bool = false
    func requestHealthKitAccess() async throws {
        guard !shouldFailRequest else { throw CustomError.errorAlert }
    }
    
    var fetchTodayStepsResult: Int = 0
    func fetchTodaySteps(completion: @escaping (Int) -> Void) {
        completion(fetchTodayStepsResult)
    }
    
    var fetchDailyStepsResult: [DailyStepModel] = []
    func fetchDailySteps(startDate: Date, completion: @escaping ([DailyStepModel]) -> Void) {
        completion(fetchDailyStepsResult)
    }
    
    var fetchTodayCaloriesResult: Int = 0
    func fetchTodayCalories(completion: @escaping (Int) -> Void) {
        completion(fetchTodayCaloriesResult)
    }
    
    
}
