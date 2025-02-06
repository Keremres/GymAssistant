//
//  View+EXT.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 23.01.2025.
//

import Foundation
import SwiftUI

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
