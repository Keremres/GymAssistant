//
//  DetailStepper.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 3.08.2024.
//

import SwiftUI

struct DetailStepper: View {
    @Binding var exercise: Exercises
    var body: some View {
        GroupBox{
            Stepper("Set: \(exercise.set)", value: $exercise.set, in: 0...20, step: 1)
            Stepper("Again: \(exercise.again)", value: $exercise.again, in: 0...20, step: 1)
            Stepper("Weight: \(exercise.weight, specifier: "%.2f")", value: $exercise.weight, in: 0...500, step: 1.25)
        }label: {
            NavigationLink(destination: ChartView(exercise: exercise)
                .navigationBarBackButtonHidden(true)
            ){
                Text("\(exercise.exercise) \(exercise.set) x \(exercise.again) : \(exercise.weight, specifier: "%.2f")").bold().foregroundStyle(.tabBar)
            }
        }
    }
}

#Preview {
    DetailStepper(exercise: .constant(DayModel.MOCK_DAY[0].exercises[0]))
}
