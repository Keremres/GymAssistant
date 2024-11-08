//
//  CreateView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 1.08.2024.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: CreateViewModel = CreateViewModel()
    
    var body: some View {
        NavigationStack{
            List{
                createTopContent
                creatingDay
                saveButton
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(CreateText.createTitle)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
            ToolbarItem(placement: .topBarTrailing){
                plusButton
            }
        }
    }
}

#Preview {
    NavigationStack{
        CreateView()
    }
}

extension CreateView {
    private var createTopContent: some View {
        Section{
            BaseTextField(textTitle: CreateText.programName,
                          textField: $viewModel.program.programName)
            Picker("\(CreateText.chooseClass): \(viewModel.program.programClass)",
                   systemImage: SystemImage.figureRunSquareStackFill,
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
                            Label(CreateText.delete, systemImage: SystemImage.trash)
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
                Text(DialogText.save)
                    .font(.system(size: 22))
                    .onTapGesture {
                        viewModel.showDialog.toggle()
                    }
                    .confirmationDialog(DialogText.save, isPresented: $viewModel.showDialog, titleVisibility: .visible){
                        Button(DialogText.cancel, role: .cancel, action: {})
                        Button(DialogText.save, action: {
                            Task{
                                await viewModel.create()
                                dismiss()
                            }
                        })
                        Button(DialogText.publish, action: {
                            Task{
                                await viewModel.publishProgram()
                                dismiss()
                            }
                        })
                    } message: {
                        Text(DialogText.areYouSure)
                    }
                Spacer()
            }
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
                    viewModel.addDay()
                }
            }
    }
}
