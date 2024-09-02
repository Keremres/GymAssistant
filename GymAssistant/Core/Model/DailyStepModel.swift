//
//  DailyStepView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 8.08.2024.
//

import Foundation

struct DailyStepModel: Identifiable{
    let id = UUID().uuidString
    let date: Date
    let stepCount: Int
}
