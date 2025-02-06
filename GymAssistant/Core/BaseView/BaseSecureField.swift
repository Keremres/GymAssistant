//
//  BaseSecureField.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct BaseSecureField: View {
    var textTitle: String
    var textField: Binding<String>
    var body: some View {
        SecureField(textTitle, text: textField)
            .padding(UIScreen.main.bounds.height * 0.01073)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))
            .font(.title2)
    }
}
