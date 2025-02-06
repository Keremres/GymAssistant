//
//  ProgramHistory.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import SwiftUI

struct ProgramHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ProgramHistoryViewModel
    
    init(programManager: ProgramManager = AppContainer.shared.programManager,
         userManager: UserManager = AppContainer.shared.userManager) {
        _viewModel = StateObject(wrappedValue: ProgramHistoryViewModel(programManager: programManager, userManager: userManager))
    }
    
    var body: some View {
        NavigationStack {
            if !viewModel.programHistory.isEmpty {
                programHistoryCard
            } else {
                emptyHistory
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                dismissButton
            }
        }
        .showAlert(alert: $viewModel.alert)
        .onDisappear {
            viewModel.cancelTasks()
        }
    }
}

#Preview {
    NavigationStack{
        ProgramHistoryView()
    }
}

extension ProgramHistoryView {
    private var programHistoryCard: some View {
        List {
            ForEach(viewModel.programHistory) { program in
                ProgramBoxView(program: program)
                    .swipeActions {
                        Button(role: .destructive) {
                                viewModel.programDelete(program: program)
                        } label: {
                            Label(LocaleKeys.Person.delete.localized, systemImage: SystemImage.trash)
                                .symbolVariant(.fill)
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyHistory: some View {
        ContentUnavailableView(
            label: {
                Label(LocaleKeys.Person.empty.localized, systemImage: SystemImage.trayFill)
            },
            description: {
                Text(LocaleKeys.Person.emptyText.localized)
            }
        )
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
