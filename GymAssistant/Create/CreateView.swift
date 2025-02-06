//
//  CreateView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 1.08.2024.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateViewModel
    @FocusState private var focusedField: FocusedField?
    
    init(programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        _viewModel = StateObject(wrappedValue: CreateViewModel(programManager: programManager, userManager: userManager))
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        focusedField = nil
                    }
                
                List{
                    createTopContent
                        .listSectionSeparator(.hidden)
                    creatingDay
                        .listSectionSeparator(.hidden)
                    saveButton
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(LocaleKeys.Create.createTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
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
            BaseTextField(textTitle: LocaleKeys.Create.programName.localized,
                          textField: $viewModel.program.programName)
            .focused($focusedField, equals: .programName)
            Picker("\(LocaleKeys.Create.chooseClass.localized): \(viewModel.program.programClass)",
                   systemImage: SystemImage.figureRunSquareStackFill,
                   selection: $viewModel.program.programClass){
                ForEach(ProgramClass.programClass, id: \.self){ className in
                    Text(className)
                }
            }
                   .foregroundStyle(.red)
        }
        .listRowBackground(Color.background.onTapGesture {
            focusedField = nil
        })
        .listRowSeparator(.hidden)
    }
    
    private var creatingDay: some View {
        ForEach(viewModel.program.week[0].day.indices, id: \.self){ index in
            NavigationLink(destination: CreateDayExercise(dayIndex: index)
                .environmentObject(viewModel)
                .navigationBarBackButtonHidden(true)){
                    dayCard(day: viewModel.program.week[0].day[index])
                        .listSectionSeparator(.hidden)
                }
                .swipeActions{
                    if viewModel.program.week[0].day.count > 1{
                        Button(role: .destructive){
                            withAnimation(.easeInOut){
                                viewModel.deleteDay(id: viewModel.program.week[0].day[index].id)
                            }
                        } label: {
                            Label(LocaleKeys.Create.delete.localized, systemImage: SystemImage.trash)
                                .symbolVariant(.fill)
                        }
                    }
                }
        }
        .listRowBackground(Color.background.onTapGesture {
            focusedField = nil
        })
    }
    
    private func dayCard(day: DayModel) -> some View {
        Section{
            VStack(alignment: .leading){
                Text(LocalizedStringKey(day.day))
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
                BaseButton(onTab: {
                    viewModel.showDialog.toggle()
                }, title: LocaleKeys.Dialog.save.localized)
                .confirmationDialog(LocaleKeys.Dialog.save.localized, isPresented: $viewModel.showDialog, titleVisibility: .visible){
                    Button(LocaleKeys.Dialog.cancel.localized, role: .cancel, action: {})
                    Button(LocaleKeys.Dialog.save.localized, action: {
                        viewModel.create()
                        dismiss()
                    })
                    Button(LocaleKeys.Dialog.publish.localized, action: {
                        viewModel.publishProgram()
                        dismiss()
                    })
                } message: {
                    Text(LocaleKeys.Dialog.areYouSure.localized)
                }
                Spacer()
            }
        }
        .listRowBackground(Color.background.onTapGesture {
            focusedField = nil
        })
    }
    
    private var dismissButton: some View {
        Image(systemName: SystemImage.chevronLeft)
            .imageScale(.large)
            .bold()
            .frame(width: 44, height: 44)
            .background {
                Color.background.opacity(0.0001)
            }
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

extension CreateView {
    private enum FocusedField: Hashable {
        case programName
    }
}
