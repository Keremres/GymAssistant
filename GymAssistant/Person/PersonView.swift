//
//  PersonView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject var programManager: ProgramManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var authManager: AuthManager
    @StateObject var viewModel: PersonViewModel
    @State var programOut = false
    @State var signOut = false
    @State var deleteAccount = false
    
    init(authManager: AuthManager, userManager: UserManager, programManager: ProgramManager) {
        _viewModel = StateObject(wrappedValue: PersonViewModel(authManager: authManager,
                                                               userManager: userManager,
                                                               programManager: programManager))
    }
    
    var body: some View {
        NavigationStack{
            List{
                accountSection
                programSection
                outSection
            }
            .listStyle(PlainListStyle())
        }
    }
}

#Preview {
    let authManager = AuthManager(service: FirebaseAuthService())
    let programManager = ProgramManager(service: FirebaseProgramService())
    let userManager = UserManager(service: FirebaseUserService(), authManager: authManager)
    NavigationStack{
        PersonView(authManager: authManager, userManager: userManager, programManager: programManager)
            .environmentObject(userManager)
            .environmentObject(authManager)
            .environmentObject(programManager)
    }
}

extension PersonView {
    private var accountSection: some View {
        Section("ACCOUNT"){
            if let userInfo = userManager.userInfo{
                HStack{
                    Text(userInfo.initials)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tabBar)
                        .frame(width: CGFloat(72),height: CGFloat(72))
                        .background(Color(.systemGray3))
                        .clipShape(.circle)
                    
                    VStack(alignment: .leading, spacing: CGFloat(4)){
                        if let firstName = userInfo.firstName{
                            HStack{
                                Text(firstName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if let lastName = userInfo.lastName{
                                    Text(lastName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }.padding(.top, 4)
                        }
                        if let email = userInfo.email{
                            Text(email)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        if let createdAt = userInfo.creationDate{
                            Text(createdAt.formatted(.dateTime))
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var programSection: some View {
        Section("Program"){
            NavigationLink {
                ProgramHistoryView(programManager: programManager, userManager: userManager)
                    .navigationBarBackButtonHidden(true)
            } label: {
                Label("Progarm history", systemImage: "clock")
                    .foregroundStyle(.tabBar)
            }
            
            Label("Program out", systemImage: "trash.fill")
                .foregroundStyle(.red)
                .onTapGesture {
                    programOut.toggle()
                }
                .alert("Program out", isPresented: $programOut) {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Program out", role: .destructive, action: {
                        Task{
                            await viewModel.programOut()
                        }
                    })
                } message: {
                    Text("You are about to exit the program. Are you sure you want to quit?")
                }
        }
    }
    
    private var outSection: some View {
        Section("Out"){
            deleteAccountButton
            signOutButton
        }
    }
    
    private var deleteAccountButton: some View {
        HStack{
            Image(systemName: "trash.fill")
            Text("Delete account")
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onLongPressGesture {
            deleteAccount.toggle()
        }
        .alert("Delete account", isPresented: $deleteAccount){
            Button("Cancel", role: .cancel, action: {})
            Button("Delete account", role: .destructive, action: {
                Task{
                    await viewModel.deleteAccount()
                }
            })
        } message: {
            Text("Account deletion cannot be undone. Are you sure?")
        }
    }
    
    private var signOutButton: some View {
        HStack{
            Image(systemName: "arrow.left.circle.fill")
            Text("Sign out")
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onTapGesture {
            signOut.toggle()
        }
        .alert("Sign out", isPresented: $signOut){
            Button("Cancel", role: .cancel, action: {})
            Button("Sign out", role: .destructive, action: {
                viewModel.signOut()
            })
        } message: {
            Text("You are about to exit. Do you want to Sign out?")
        }
    }
}
