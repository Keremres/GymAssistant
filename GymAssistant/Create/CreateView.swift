//
//  CreateView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 1.08.2024.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var programManager: ProgramManager
    @EnvironmentObject var userManager: UserManager
    @StateObject var viewModel: CreateViewModel
    @State var alert = false
    
    init(programManager: ProgramManager, userManager: UserManager) {
        _viewModel = StateObject(wrappedValue: CreateViewModel(programManager: programManager,
                                                               userManager: userManager))
    }
    
    var body: some View {
        NavigationStack{
            List{
                createTopContent
                creatingDay
                saveButton
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Create new program")
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
                        withAnimation(){
                            viewModel.addDay()
                        }
                    }
            }
        }
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let programManager = ProgramManager(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    NavigationStack{
        CreateView(programManager: programManager, userManager: userManager)
            .environmentObject(userManager)
            .environmentObject(programManager)
    }
}

extension CreateView {
    private var createTopContent: some View {
        Section{
            BaseTextField(textTitle: "Program name",
                          textField: $viewModel.program.programName)
            Picker("Choose Class: \(viewModel.program.programClass)",
                   systemImage: "figure.run.square.stack.fill",
                   selection: $viewModel.program.programClass){
                ForEach(ProgramClass.programClass, id: \.self){ className in
                    Text(className)
                }
            }
            .foregroundStyle(.red)
        }
    }
    
    private var creatingDay: some View {
        ForEach(viewModel.program.week[0].day.indices, id: \.self){ index in
            NavigationLink(destination: CreateDayExercise(dayIndex: index)
                .environmentObject(viewModel)
                .navigationBarBackButtonHidden(true)){
                    dayCard(day: viewModel.program.week[0].day[index])
                }
                .swipeActions{
                    if viewModel.program.week[0].day.count > 1{
                        Button(role: .destructive){
                            withAnimation(.easeInOut){
                                viewModel.deleteDay(id: viewModel.program.week[0].day[index].id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .symbolVariant(.fill)
                        }
                    }
                }
        }
    }
    
    private func dayCard(day: DayModel) -> some View {
        Section{
            VStack(alignment: .leading){
                Text(day.day)
                    .bold()
                    .foregroundStyle(.red)
                ForEach(day.exercises.indices, id: \.self){ index in
                    Text("\(day.exercises[index].exercise) : ") +
                    Text("\(day.exercises[index].set) x ") +
                    Text(day.exercises[index].againStart.description) +
                    Text(day.exercises[index].againEnd != 0 ? " - \(day.exercises[index].againEnd)" : "") +
                    Text(" = \(day.exercises[index].weight , specifier: "%.2f")")
                }
            }
        }
    }
    
    private var saveButton: some View {
        Section{
            HStack{
                Spacer()
                Text("Save")
                    .font(.system(size: 22))
                    .onTapGesture {
                        alert.toggle()
                    }
                    .alert("Save", isPresented: $alert){
                        Button("Cancel", role: .cancel, action: {})
                        Button("Save", action: {
                            Task{
                                await viewModel.create()
                                dismiss()
                            }
                        })
                        Button("Publish", action: {
                            Task{
                                await viewModel.publishProgram()
                                dismiss()
                            }
                        })
                    } message: {
                        Text("Are you sure you want to save")
                    }
                Spacer()
            }
        }
    }
}
