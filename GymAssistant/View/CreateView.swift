//
//  CreateView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 1.08.2024.
//

import SwiftUI


struct CreateView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = CreateViewModel()
    @State var alert = false
    @State var sheet = false
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    var body: some View {
        NavigationStack{
            List{
                Section{
                    BaseTextField(textTitle: "Program name", textField: $viewModel.program.programName)
                    Picker("Choose Class: \(viewModel.program.programClass)", systemImage: "figure.run.square.stack.fill", selection: $viewModel.program.programClass){
                        ForEach(ProgramClass.programClass, id: \.self){ className in
                            Text(className)
                        }
                    }
                    .foregroundStyle(.red)
                }
                ForEach($viewModel.program.week[0].day){ $day in
                    CreateBoxView(viewModel: viewModel, dayModel: $day, sheet: $sheet)
                        .swipeActions{
                            if viewModel.program.week[0].day.count > 1{
                                Button(role: .destructive){
                                    withAnimation{
                                        viewModel.deleteDay(id: day.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash").symbolVariant(.fill)
                                }
                            }
                        }
                }
                Section{
                    HStack{
                        Spacer()
                        Text("Save")
                            .font(.system(size: 22))
                            .onTapGesture {
                                alert.toggle()
                            }.alert("Save", isPresented: $alert){
                                Button("Cancel", role: .cancel, action: {})
                                Button("Save", action: {
                                    Task{
                                        try await viewModel.create(user: mainTabViewModel.user)
                                        dismiss()
                                    }
                                })
                                Button("Publish", action: {
                                    Task{
                                        try await viewModel.publishProgram()
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
        }.navigationTitle("Create new program")
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .bold()
                        .onTapGesture {
                            dismiss()
                        }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .bold()
                        .onTapGesture {
                            withAnimation{
                                viewModel.addDay()
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
    NavigationStack{
        CreateView()
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
    }
}
