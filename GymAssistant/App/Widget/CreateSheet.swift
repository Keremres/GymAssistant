//
//  CreateSheet.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 19.08.2024.
//

import SwiftUI

struct CreateSheet: View {
    @State var exercise:Exercises = .init(exercise: "")
    @Binding var sheet: Bool
    var body: some View {
        VStack{
            Text("New Exercise")
                .font(.largeTitle)
            BaseTextField(textTitle: "Exercise Name", textField: $exercise.exercise)
            BaseButton(onTab: {
                Exercises.exerciseList.append(exercise)
                withAnimation{
                    sheet = false
                }
            }, title: "Save")
            .padding(.top, CGFloat(5))
            .disabled(exercise.exercise.isEmpty)
        }
    }
}

#Preview {
    CreateSheet(sheet: .constant(false))
}
