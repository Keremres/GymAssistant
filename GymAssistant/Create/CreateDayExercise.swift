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
        .navigationBarTitle("Create Day Exercise")
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .bold()
                    .onTapGesture {
                        withAnimation{
                            dismiss()
                        }
                    }
            }
            ToolbarItem(placement: .topBarTrailing){
                Image(systemName: "plus")
                    .imageScale(.large)
                    .bold()
                    .onTapGesture {
                        withAnimation{
                            createViewModel.addExercises(dayModel: createViewModel.program.week[0].day[dayIndex])
                        }
                    }
            }
        }
        .sheet(isPresented: $sheet){
            CreateSheet(sheet: $sheet)
                .presentationDetents([.fraction(0.3)])
        }
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    let programManager = ProgramManager(service: FirebaseProgramService())
    NavigationStack{
        CreateDayExercise(dayIndex: 0)
            .environmentObject(CreateViewModel(programManager: programManager,
                                               userManager: userManager))
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
                            Image(systemName: "plus.app")
                            Text("New")
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
                    Label("Delete", systemImage: "trash")
                        .symbolVariant(.fill)
                }
            }
        }
    }
    
    private var selectDay: some View {
        Picker("Choose day: \(createViewModel.program.week[0].day[dayIndex].day)", systemImage: "calendar", selection: $createViewModel.program.week[0].day[dayIndex].day){
            ForEach(Weekday.weekday, id: \.self){ day in
                Text(day)
            }
        }
        .foregroundColor(.red)
    }
    
    private func stepperViews(for exercise: Binding<Exercises>) -> some View {
        VStack {
            Stepper("Set: \(exercise.set.wrappedValue)",
                    value: exercise.set,
                    in: 0...20,
                    step: 1)
            Stepper("Repeat: \(exercise.againStart.wrappedValue)",
                    value: exercise.againStart,
                    in: 0...20,
                    step: 1)
            Stepper("Repeat interval: \(exercise.againEnd.wrappedValue)",
                    value: exercise.againEnd,
                    in: 0...20,
                    step: 1)
            Stepper("Weight: \(exercise.weight.wrappedValue, specifier: "%.2f")",
                    value: exercise.weight,
                    in: 0...500,
                    step: 1)
        }
    }
}
