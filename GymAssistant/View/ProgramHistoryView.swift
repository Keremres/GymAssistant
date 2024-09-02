//
//  ProgramHistory.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 24.08.2024.
//

import SwiftUI

struct ProgramHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ProgramHistoryViewModel = ProgramHistoryViewModel()
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    var body: some View {
        NavigationStack {
            if !viewModel.programHistory.isEmpty {
                List {
                    ForEach(viewModel.programHistory) { program in
                        ProgramBoxView(program: program)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task{
                                        await viewModel.programDelete(user: mainTabViewModel.user, program: program)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash").symbolVariant(.fill)
                                }
                            }
                    }
                }
            } else {
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
        .onAppear {
            Task {
                do {
                    try await viewModel.programHistory(user: mainTabViewModel.user)
                } catch {
                    print("Failed to load program history")
                }
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
        .alert(viewModel.errorTitle, isPresented: $viewModel.error) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationStack{
        ProgramHistoryView()
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
    }
}
