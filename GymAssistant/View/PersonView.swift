//
//  PersonView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject var programService: ProgramService
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @StateObject var viewModel = PersonViewModel()
    @State var programOut = false
    @State var signOut = false
    var body: some View {
        NavigationStack{
            List{
                Section("ACCOUNT"){
                    HStack{
                        Text(mainTabViewModel.user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tabBar)
                            .frame(width: CGFloat(72),height: CGFloat(72))
                            .background(Color(.systemGray3))
                            .clipShape(.circle)
                        
                        VStack(alignment: .leading, spacing: CGFloat(4)){
                            Text(mainTabViewModel.user.username)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, CGFloat(4))
                            Text(mainTabViewModel.user.email)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                Section("Program"){
                    NavigationLink {
                        ProgramHistoryView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Label("Progarm history", systemImage: "clock")
                            .foregroundStyle(.tabBar)
                    }

                    Label("Program out", systemImage: "trash.fill")
                        .foregroundStyle(.red)
                        .onTapGesture {
                            programOut.toggle()
                        }.alert("Program out", isPresented: $programOut) {
                            Button("Cancel", role: .cancel, action: {})
                            Button("Program out", role: .destructive, action: {
                                Task{
                                    try await viewModel.programOut(user: mainTabViewModel.user)
                                }
                            })
                        } message: {
                            Text("You are about to exit the program. Are you sure you want to quit?")
                        }
                }
                Section("Out"){
                    HStack{
                        Image(systemName: "arrow.left.circle.fill")
                        Text("Sign out")
                    }
                    .font(.system(size: 20))
                    .foregroundStyle(.red)
                }.onTapGesture {
                    signOut.toggle()
                }.alert("Sign out", isPresented: $signOut){
                    Button("Cancel", role: .cancel, action: {})
                    Button("Sign out", role: .destructive, action: {
                            viewModel.signOut()
                    })
                } message: {
                    Text("You are about to exit. Do you want to Sign out?")
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        PersonView()
            .environmentObject(ProgramService())
            .environmentObject(MainTabViewModel(user: User.MOCK_USER))
    }
}
