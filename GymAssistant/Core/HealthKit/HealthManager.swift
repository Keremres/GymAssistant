//
//  HealthManager.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 5.08.2024.
//

import Foundation
import HealthKit

final class HealthManager{
    
    static let shared = HealthManager()
    let healthStore = HKHealthStore()
    
    init(){
        
        Task{
            do{
                try await requestHealthKitAccess()
            }catch{
                print("error fetching health data")
            }
        }
    }
    
    func requestHealthKitAccess() async throws {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let healthTypes: Set = [steps, calories]
        try await healthStore.requestAuthorization(toShare: [],read: healthTypes)
    }
    
    func fetchTodaySteps(completion: @escaping(Int) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate){ _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            completion(Int(stepCount))
        }
        healthStore.execute(query)
    }
    
    func fetchDailySteps(startDate: Date, completion: @escaping([DailyStepModel]) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
            guard let result = result, error == nil else{
                return
            }
            var dailySteps = [DailyStepModel]()
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                dailySteps.append(DailyStepModel(date: statistics.startDate, stepCount: Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)))
            }
            completion(dailySteps)
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalories(completion: @escaping(Int) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate){ _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                return
            }
            let caloriesCount = quantity.doubleValue(for: .kilocalorie())
            completion(Int(caloriesCount))
        }
        healthStore.execute(query)
    }
}

extension Double{
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
