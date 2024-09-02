//
//  CreateBoxView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import SwiftUI

struct CreateBoxView: View {
    @ObservedObject var viewModel: CreateViewModel
    @Binding var dayModel: DayModel
    @Binding var sheet: Bool
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Image(systemName: "plus")
                    .bold()
                    .onTapGesture {
                        viewModel.addExercises(id: dayModel.id)
                    }
            }
            Section{
                Picker("Choose day: \(dayModel.day)", systemImage: "calendar", selection: $dayModel.day){
                    ForEach(Weekday.weekday, id: \.self){ day in
                        Text(day)
                    }
                }
                .foregroundColor(.red)
            }
            .padding(.top, 10)
            ScrollView{
                ForEach($dayModel.exercises) { $exercise in
                    Section{
                        CreatePicker(exercise: $exercise, sheet: $sheet)
                        Stepper("Set: \(exercise.set)", value: $exercise.set, in: 0...20, step: 1)
                        Stepper("Repeat: \(exercise.againStart)", value: $exercise.againStart, in: 0...20, step: 1)
                        Stepper("Repeat interval: \(exercise.againEnd)", value: $exercise.againEnd
                                , in: 0...20, step: 1)
                        Stepper("Weight: \(exercise.weight, specifier: "%.2f")", value: $exercise.weight, in: 0...500, step: 1)
                        
                    }
                    .onChange(of: exercise.againStart){
                        exercise.again = exercise.againStart
                    }
                }
            }.frame(height: UIScreen.main.bounds.height * 0.225)
        }
    }
}

#Preview {
    CreateBoxView(viewModel: CreateViewModel(), dayModel: .constant(DayModel.MOCK_DAY[0]), sheet: .constant(false))
}
