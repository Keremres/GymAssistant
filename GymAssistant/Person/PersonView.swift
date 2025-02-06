//
//  PersonView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct PersonView: View {
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var viewModel: PersonViewModel
    
    init(authManager: AuthManager = AppContainer.shared.authManager,
         userManager: UserManager = AppContainer.shared.userManager,
         programManager: ProgramManager = AppContainer.shared.programManager) {
        _viewModel = StateObject(wrappedValue: PersonViewModel(authManager: authManager, userManager: userManager, programManager: programManager))
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
    NavigationStack{
        PersonView()
            .environmentObject(AppContainer.shared.userManager)
    }
}

extension PersonView {
    private var accountSection: some View {
        Section(LocaleKeys.Person.account.localized){
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
        Section(LocaleKeys.Person.program.localized){
            NavigationLink {
                ProgramHistoryView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                Label(LocaleKeys.Person.programHistory.localized, systemImage: SystemImage.clock)
                    .foregroundStyle(.tabBar)
            }
            
            Label(LocaleKeys.Dialog.programOut.localized, systemImage: SystemImage.trashFill)
                .foregroundStyle(.red)
                .onTapGesture {
                    viewModel.programOutDialog.toggle()
                }
                .confirmationDialog(LocaleKeys.Dialog.programOut.localized, isPresented: $viewModel.programOutDialog, titleVisibility: .visible){
                    Button(LocaleKeys.Dialog.cancel.localized, role: .cancel, action: {})
                    Button(LocaleKeys.Dialog.programOut.localized, role: .destructive, action: {
                        viewModel.programOut()
                    })
                } message: {
                    Text(LocaleKeys.Dialog.programOutText.localized)
                }
        }
    }
    
    private var outSection: some View {
        Section(LocaleKeys.Person.out.localized){
            deleteAccountButton
            signOutButton
        }
    }
    
    private var deleteAccountButton: some View {
        HStack{
            Image(systemName: SystemImage.trashFill)
            Text(LocaleKeys.Dialog.deleteAccount.localized)
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onLongPressGesture {
            viewModel.deleteAccountDialog.toggle()
        }
        .confirmationDialog(LocaleKeys.Dialog.deleteAccount.localized, isPresented: $viewModel.deleteAccountDialog, titleVisibility: .visible){
            Button(LocaleKeys.Dialog.cancel.localized, role: .cancel, action: {})
            Button(LocaleKeys.Dialog.deleteAccount.localized, role: .destructive, action: {
                viewModel.deleteAccount()
            })
        } message: {
            Text(LocaleKeys.Dialog.deleteAccountText.localized)
        }
    }
    
    private var signOutButton: some View {
        HStack{
            Image(systemName: SystemImage.arrowLeftCircleFill)
            Text(LocaleKeys.Dialog.signOut.localized)
        }
        .font(.system(size: 20))
        .foregroundStyle(.red)
        .onTapGesture {
            viewModel.signOutDialog.toggle()
        }
        .confirmationDialog(LocaleKeys.Dialog.signOut.localized, isPresented: $viewModel.signOutDialog, titleVisibility: .visible){
            Button(LocaleKeys.Dialog.cancel.localized, role: .cancel, action: {})
            Button(LocaleKeys.Dialog.signOut.localized, role: .destructive, action: {
                viewModel.signOut()
            })
        } message: {
            Text(LocaleKeys.Dialog.signOutText.localized)
        }
    }
}
