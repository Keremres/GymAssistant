//
//  CreatePicker.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 19.08.2024.
//

import SwiftUI

struct CreatePicker: View {
    @Binding var exercise: Exercises
    @State private var movement = 0
    var body: some View {
        Picker("\(LocaleKeys.Create.exercise.localized): \(exercise.exercise)", systemImage: SystemImage.dumbbellFill, selection: $movement){
                ForEach(Exercises.exerciseList.indices, id: \.self){ index in
                    Text(Exercises.exerciseList[index].exercise)
                }
                .onChange(of: movement){
                    exercise = Exercises.exerciseList[movement]
                }
            }
            .tint(.gray)
        .foregroundStyle(.red)
        .onAppear {
            if let initialIndex = Exercises.exerciseList.firstIndex(where: { $0.id == exercise.id }) {
                movement = initialIndex
            }
        }
    }
}

#Preview {
    CreatePicker(exercise: .constant(Exercises.exerciseList[0]))
}
