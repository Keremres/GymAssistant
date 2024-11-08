//
//  CreateDayExercise.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 26.10.2024.
//

import SwiftUI

struct CreateDayExercise: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var createViewModel: CreateViewModel
    let dayIndex: Int
    @State var sheet: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                selectDay
                sectons
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitle(CreateText.createDayTitle)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
            ToolbarItem(placement: .topBarTrailing){
                plusButton
            }
        }
        .sheet(isPresented: $sheet){
            CreateSheet(sheet: $sheet)
                .presentationDetents([.fraction(0.3)])
        }
    }
}

#Preview {
    NavigationStack{
        CreateDayExercise(dayIndex: 0)
            .environmentObject(CreateViewModel())
    }
}

extension CreateDayExercise {
    private var sectons: some View {
        ForEach(createViewModel.program.week[0].day[dayIndex].exercises.indices, id: \.self){ index in
            Section{
                VStack{
                    HStack{
                        CreatePicker(exercise: $createViewModel.program.week[0].day[dayIndex].exercises[index])
                        Spacer(minLength: 10)
                        HStack{
                            Image(systemName: SystemImage.plusApp)
                            Text(CreateText.new)
                        }
                        .font(.title3)
                        .foregroundStyle(.red)
                        .onTapGesture{
                            withAnimation{
                                sheet = true
                            }
                        }
                    }
                    stepperViews(for: $createViewModel.program.week[0].day[dayIndex].exercises[index])
                }
            }
            .swipeActions{
                Button(role: .destructive){
                    withAnimation{
                        createViewModel.deleteExercise(idExercise: createViewModel.program.week[0].day[dayIndex].exercises[index].id,
                                                       idDayModel: createViewModel.program.week[0].day[dayIndex].id)
                    }
                } label: {
                    Label(CreateText.delete, systemImage: SystemImage.trash)
                        .symbolVariant(.fill)
                }
            }
        }
    }
    
    private var selectDay: some View {
        Picker("\(CreateText.chooseDay): \(createViewModel.program.week[0].day[dayIndex].day)", systemImage: SystemImage.calendar, selection: $createViewModel.program.week[0].day[dayIndex].day){
            ForEach(Weekday.weekday, id: \.self){ day in
                Text(day)
            }
        }
        .foregroundColor(.red)
    }
    
    private func stepperViews(for exercise: Binding<Exercises>) -> some View {
        VStack {
            Stepper("\(CreateText.set): \(exercise.set.wrappedValue)",
                    value: exercise.set,
                    in: 0...20,
                    step: 1)
            Stepper("\(CreateText.repeatText): \(exercise.againStart.wrappedValue)",
                    value: exercise.againStart,
                    in: 0...20,
                    step: 1)
            Stepper("\(CreateText.repeatInterval): \(exercise.againEnd.wrappedValue)",
                    value: exercise.againEnd,
                    in: 0...20,
                    step: 1)
            Stepper("\(CreateText.weight): \(exercise.weight.wrappedValue, specifier: "%.2f")",
                    value: exercise.weight,
                    in: 0...500,
                    step: 1)
        }
    }
    
    private var dismissButton: some View {
        Image(systemName: SystemImage.chevronLeft)
            .imageScale(.large)
            .bold()
            .onTapGesture {
                withAnimation{
                    dismiss()
                }
            }
    }
    
    private var plusButton: some View {
        Image(systemName: SystemImage.plus)
            .imageScale(.large)
            .bold()
            .onTapGesture {
                withAnimation(){
                    createViewModel.addExercises(dayModel: createViewModel.program.week[0].day[dayIndex])
                }
            }
    }
}
