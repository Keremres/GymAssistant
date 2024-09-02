//
//  DateExtension.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 6.08.2024.
//

import Foundation

extension Date{
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        return calendar.date(from: components) ?? Date()
    }
    static var oneMonthAgo: Date{
        let calendar = Calendar.current
        let oneMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return calendar.startOfDay(for: oneMonth)
    }
    
    
    static var getCurrentWeekStartDate: Date{
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        return startOfWeek
    }
    static func getCurrentWeekInt(date: Date) -> Int {
            let calendar = Calendar.current
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            return weekOfYear
        }
}
