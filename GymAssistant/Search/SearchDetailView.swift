//
//  SearchDetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.08.2024.
//

import SwiftUI

struct SearchDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var searchViewModel: SearchViewModel
    @State var alert = false
    let program: Program
    var body: some View {
        NavigationStack{
            ScrollView{
                programWeekDays
                BaseButton(onTab: {alert.toggle()},
                           title: "Use Program")
                .padding(.top, 16)
                .alert("Use Program", isPresented: $alert){
                    Button("Cancel", role: .cancel, action: {})
                    Button("Use Program", action: {
                        Task{
                            await searchViewModel.useProgram(program: program)
                            dismiss()
                        }
                    })
                } message: {
                    Text("Are you sure you want to save")
                }
            }
        }.navigationTitle(program.programName)
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .bold()
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    let programManager = ProgramManager(service: FirebaseProgramService())
    NavigationStack{
        SearchDetailView(searchViewModel: SearchViewModel(programManager: programManager, userManager: userManager), program: Program.MOCK_PROGRAM)
    }
}

extension SearchDetailView {
    private var programWeekDays: some View {
        ForEach(program.week[0].day){ day in
            DayGroupBox(dayModel: day, change: false)
        }
    }
}
