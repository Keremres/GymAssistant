//
//  CreateSheet.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 19.08.2024.
//

import SwiftUI

struct CreateSheet: View {
    @State var exercise:Exercises = .init(exercise: "")
    @FocusState private var focusedField: FocusedField?
    @Binding var sheet: Bool
    var body: some View {
        ZStack{
            Color.background
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack{
                Text(LocaleKeys.Create.newExercise.localized)
                    .font(.largeTitle)
                BaseTextField(textTitle: LocaleKeys.Create.exerciseName.localized,
                              textField: $exercise.exercise)
                .focused($focusedField, equals: .exerciseName)
                BaseButton(onTab: {
                    Exercises.exerciseList.append(exercise)
                    withAnimation{
                        sheet = false
                    }
                }, title: LocaleKeys.Dialog.save.localized)
                .padding(.top, CGFloat(5))
                .disabled(exercise.exercise.isEmpty)
            }
        }
    }
}

#Preview {
    CreateSheet(sheet: .constant(false))
}

extension CreateSheet {
    private enum FocusedField: Hashable {
        case exerciseName
    }
}
