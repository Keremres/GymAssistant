//
//  RefreshIntent.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.01.2025.
//

import SwiftUI
import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
