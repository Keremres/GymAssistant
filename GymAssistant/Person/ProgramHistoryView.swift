//
//  ProgramHistory.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import SwiftUI

struct ProgramHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var programManager: ProgramManager
    @StateObject var viewModel: ProgramHistoryViewModel
    
    init(programManager: ProgramManager, userManager: UserManager) {
        _viewModel = StateObject(wrappedValue: ProgramHistoryViewModel(programManager: programManager,
                                                                       userManager: userManager))
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
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .bold()
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
        .showAlert(alert: $viewModel.alert)
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let programManager = ProgramManager(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    NavigationStack{
        ProgramHistoryView(programManager: programManager, userManager: userManager)
            .environmentObject(userManager)
            .environmentObject(programManager)
    }
}

extension ProgramHistoryView {
    private var programHistoryCard: some View {
        List {
            ForEach(viewModel.programHistory) { program in
                ProgramBoxView(program: program)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task{
                                await viewModel.programDelete(program: program)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
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
                Label("No Program History Found", systemImage: "tray.fill")
            },
            description: {
                Text("You don't have any program history")
            }
        )
    }
}
