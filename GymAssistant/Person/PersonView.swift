//
//  PersonView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject var viewModel: PersonViewModel = PersonViewModel()
    
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
    NavigationStack{
        PersonView()
            .environmentObject(AppContainer.shared.userManager)
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
                ProgramHistoryView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                Label("Progarm history", systemImage: SystemImage.clock)
                    .foregroundStyle(.tabBar)
            }
            
            Label(DialogText.programOut, systemImage: SystemImage.trashFill)
                .foregroundStyle(.red)
                .onTapGesture {
                    viewModel.programOutDialog.toggle()
                }
                .confirmationDialog(DialogText.programOut, isPresented: $viewModel.programOutDialog, titleVisibility: .visible){
                    Button(DialogText.cancel, role: .cancel, action: {})
                    Button(DialogText.programOut, role: .destructive, action: {
                        Task{
                            await viewModel.programOut()
                        }
                    })
                } message: {
                    Text(DialogText.programOutText)
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
            Image(systemName: SystemImage.trashFill)
            Text(DialogText.deleteAccount)
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onLongPressGesture {
            viewModel.deleteAccountDialog.toggle()
        }
        .confirmationDialog(DialogText.deleteAccount, isPresented: $viewModel.deleteAccountDialog, titleVisibility: .visible){
            Button(DialogText.cancel, role: .cancel, action: {})
            Button(DialogText.deleteAccount, role: .destructive, action: {
                Task{
                    await viewModel.deleteAccount()
                }
            })
        } message: {
            Text(DialogText.deleteAccountText)
        }
    }
    
    private var signOutButton: some View {
        HStack{
            Image(systemName: SystemImage.arrowLeftCircleFill)
            Text(DialogText.signOut)
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onTapGesture {
            viewModel.signOutDialog.toggle()
        }
        .confirmationDialog(DialogText.signOut, isPresented: $viewModel.signOutDialog, titleVisibility: .visible){
            Button(DialogText.cancel, role: .cancel, action: {})
            Button(DialogText.signOut, role: .destructive, action: {
                viewModel.signOut()
            })
        } message: {
            Text(DialogText.signOutText)
        }
    }
}
