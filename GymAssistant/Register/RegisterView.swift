//
//  RegisterView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FocusedField?
    
    init(authManager: AuthManager = AppContainer.shared.authManager) {
        _viewModel = StateObject(wrappedValue: RegisterViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        focusedField = nil
                    }
                VStack {
                    registerBody
                    signUpButton
                }
                .padding(16)
            }
        }
        .navigationTitle(LocaleKeys.Register.signUp.localized)
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
        RegisterView()
    }
}

extension RegisterView {
    private var registerBody: some View {
        VStack {
            BaseTextField(textTitle: LocaleKeys.Register.firstName.localized,
                          textField: $viewModel.register.firstName)
            .textContentType(.givenName)
            .focused($focusedField, equals: .firstName)
            BaseTextField(textTitle: LocaleKeys.Register.lastName.localized,
                          textField: $viewModel.register.lastName)
            .textContentType(.familyName)
            .focused($focusedField, equals: .lastName)
            .padding(.top, 16)
            BaseTextField(textTitle: LocaleKeys.Register.email.localized,
                          textField: $viewModel.register.email)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .focused($focusedField, equals: .email)
            .padding(.top, 16)
            BaseSecureField(textTitle: LocaleKeys.Register.password.localized,
                            textField: $viewModel.register.password)
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .padding(.top, 16)
            BaseSecureField(textTitle: LocaleKeys.Register.verifyPassword.localized,
                            textField: $viewModel.register.verifyPassword)
            .textContentType(.password)
            .focused($focusedField, equals: .verifyPassword)
            .padding(.top, 16)
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
                dismiss()
            }
    }
    
    private var signUpButton: some View {
        BaseButton(onTab:{
            viewModel.createUser()
        }, title: LocaleKeys.Register.signUp.localized)
        .showAlert(alert: $viewModel.alert)
        .padding(.top, 16)
    }
}

extension RegisterView {
    private enum FocusedField: Hashable {
        case firstName
        case lastName
        case email
        case password
        case verifyPassword
    }
}
