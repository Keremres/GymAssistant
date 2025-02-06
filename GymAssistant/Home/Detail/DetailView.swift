//
//  DetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import SwiftUI
import Charts

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State var dayModel: DayModel
    @Environment(\.dismiss) private var dismiss
    
    init(dayModel: DayModel,
         programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(programManager: programManager, userManager: userManager))
        self.dayModel = dayModel
    }
    
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach($dayModel.exercises){ $exercises in
                    DetailStepper(exercise: $exercises)
                }
                .padding(.horizontal,16)
                BaseButton(onTab: {
                    viewModel.saveDay(dayModel: dayModel)
                    dismiss()
                }, title: LocaleKeys.Dialog.save.localized)
                .padding(.top, 16)
            }
        }
        .navigationTitle(LocalizedStringKey(dayModel.day))
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
        DetailView(dayModel: DayModel.MOCK_DAY[0])
    }
}

extension DetailView {
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
