//
//  LoginView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: FocusedField?
    
    init(authManager: AuthManager = AppContainer.shared.authManager) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        focusedField = nil
                    }
                
                VStack{
                    BaseTextField(textTitle: LocaleKeys.Login.email.localized,
                                  textField: $viewModel.signInModel.email)
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    BaseSecureField(textTitle: LocaleKeys.Login.password.localized,
                                    textField: $viewModel.signInModel.password)
                    .focused($focusedField, equals: .password)
                    .textContentType(.password)
                    .padding(.top, 16)
                    forgetPasswordButton
                    loginButton
                    signUpButton
                    loginText
                }
                .padding(16)
                .sheet(isPresented: $viewModel.showForgotPassword){
                    ForgotPassword(viewModel: viewModel)
                        .presentationDetents([.fraction(0.3)])
                }
            }
        }
    }
}

#Preview {
    LoginView()
}

extension LoginView {
    
    private var loginText: some View {
        Text(attributedString)
            .foregroundStyle(.loginText)
            .tint(.loginTextBlue)
            .padding(.top, 16)
    }
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(LocaleKeys.Login.loginText.localized)
        
        if let linkedinRange = attributedString.range(of: "linkedin") {
            attributedString[linkedinRange].link = URL(string: "https://www.linkedin.com/in/kerem-resnenli/")
            attributedString[linkedinRange].foregroundColor = .loginTextBlue
        }
        
        if let githubRange = attributedString.range(of: "github") {
            attributedString[githubRange].link = URL(string: "https://github.com/keremres")
            attributedString[githubRange].foregroundColor = .loginTextBlue
        }
        
        return attributedString
    }
    
    private var signUpButton: some View {
        HStack{
            Text(LocaleKeys.Login.signUpText.localized)
                .foregroundStyle(.loginText)
            NavigationLink(destination: RegisterView()
                .navigationBarBackButtonHidden(true)
            ){
                Text(LocaleKeys.Login.signUp.localized)
                    .foregroundStyle(.loginTextBlue)
            }
        }
        .padding(.top, 16)
    }
    
    private var forgetPasswordButton: some View {
        Text(LocaleKeys.Login.forgotPassword.localized)
            .foregroundStyle(.loginTextBlue)
            .onTapGesture {
                withAnimation{
                    viewModel.showForgotPassword = true
                }
            }
            .padding(.top, 8)
    }
    
    private var loginButton: some View {
        BaseButton(onTab: {
            viewModel.signIn()
        }, title: LocaleKeys.Login.login.localized)
        .showAlert(alert: $viewModel.alert)
        .padding(.top, 8)
    }
}

extension LoginView {
    private enum FocusedField: Hashable {
        case email
        case password
    }
}
