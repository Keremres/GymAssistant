//
//  SearchDetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 28.08.2024.
//

import SwiftUI

struct SearchDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var searchViewModel: SearchViewModel
    let program: Program
    
    var body: some View {
        NavigationStack{
            ScrollView{
                programWeekDays
                BaseButton(onTab: {searchViewModel.showDialog.toggle()},
                           title: LocaleKeys.Dialog.useProgram.localized)
                .padding(.top, 16)
                .confirmationDialog(LocaleKeys.Dialog.useProgram.localized, isPresented: $searchViewModel.showDialog, titleVisibility: .visible){
                    Button(LocaleKeys.Dialog.cancel.localized, role: .cancel, action: {})
                    Button(LocaleKeys.Dialog.useProgram.localized, action: {
                        searchViewModel.useProgram(program: program)
                        dismiss()
                    })
                } message: {
                    Text(LocaleKeys.Dialog.areYouSure.localized)
                }
            }
        }
        .navigationTitle(program.programName)
        .navigationBarTitleDisplayMode(.inline)
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
}
