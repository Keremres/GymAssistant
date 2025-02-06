//
//  GoalSettingViewModel.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 26.01.2025.
//

import Foundation
import SwiftUI
import WidgetKit

final class GoalSettingViewModel: ObservableObject {
    @AppStorage("goal", store: UserDefaults(suiteName: "group.com.keremresnenli.GymAssistant")) private var goal: Data = Data()
    @Published var stepsGoal: String = ""
    @Published var caloriesGoal: String = ""
    
    init() {
        setUp()
    }
    
    func save() {
        let newGoal: Goal = .init(stepsGoal: Int(stepsGoal) ?? 0, caloriesGoal: Int(caloriesGoal) ?? 0)
        if let data = try? JSONEncoder().encode(newGoal) {
            self.goal = data
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func setUp() {
        if let goal = try? JSONDecoder().decode(Goal.self, from: self.goal) {
            self.stepsGoal = String(goal.stepsGoal)
            self.caloriesGoal = String(goal.caloriesGoal)
        }
    }
}
