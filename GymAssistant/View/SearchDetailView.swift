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
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @State var alert = false
    let program: Program
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach(program.week[0].day){ day in
                    DayGroupBox(dayModel: day, change: false)
                }
                BaseButton(onTab: {
                    alert.toggle()
                }, title: "Use Program")
                .alert("Use Program", isPresented: $alert){
                    Button("Cancel", role: .cancel, action: {})
                    Button("Use Program", action: {
                        Task{
                            try await searchViewModel.useProgram(user: mainTabViewModel.user,program: program)
                            mainTabViewModel.newUser()
                            homeViewModel.program = program
                            dismiss()
                        }
                    })
                } message: {
                    Text("Are you sure you want to save")
                }
                .padding(.top, 16)
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
    NavigationStack{
        SearchDetailView(searchViewModel: SearchViewModel(), program: Program.MOCK_PROGRAM)
            .environmentObject(HomeViewModel())
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
    }
}
