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
    let program: Program
    
    var body: some View {
        NavigationStack{
            ScrollView{
                programWeekDays
                BaseButton(onTab: {searchViewModel.showDialog.toggle()},
                           title: DialogText.useProgram)
                .padding(.top, 16)
                .confirmationDialog(DialogText.useProgram, isPresented: $searchViewModel.showDialog, titleVisibility: .visible){
                    Button(DialogText.cancel, role: .cancel, action: {})
                    Button(DialogText.useProgram, action: {
                        Task{
                            await searchViewModel.useProgram(program: program)
                            dismiss()
                        }
                    })
                } message: {
                    Text(DialogText.areYouSure)
                }
            }
        }.navigationTitle(program.programName)
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
    }
}

#Preview {
    NavigationStack{
        SearchDetailView(searchViewModel: SearchViewModel(),
                         program: Program.MOCK_PROGRAM)
    }
}

extension SearchDetailView {
    private var programWeekDays: some View {
        ForEach(program.week[0].day){ day in
            DayGroupBox(dayModel: day, change: false)
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
}
