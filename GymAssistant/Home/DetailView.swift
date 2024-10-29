//
//  DetailView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 2.08.2024.
//

import SwiftUI
import Charts

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @State var dayModel: DayModel
    @Environment(\.dismiss) var dismiss
    
    init(dayModel: DayModel, userManager: UserManager, programManager: ProgramManager) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(userManager: userManager, programManager: programManager))
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
                    Task{
                        await viewModel.saveDay(dayModel: dayModel)
                        dismiss()
                    }
                }, title: "Save")
                .padding(.top, 16)
            }
        }
        .navigationTitle("\(dayModel.day)")
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
    let programManager = ProgramManager.init(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: AuthManager(service: FirebaseAuthService()))
    NavigationStack{
        DetailView(dayModel: DayModel.MOCK_DAY[0],
                   userManager: userManager,
                   programManager: programManager)
    }
}
