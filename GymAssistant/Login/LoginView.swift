//
//  LoginView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack{
            VStack{
                BaseTextField(textTitle: LoginText.textField,
                              textField: $viewModel.signInModel.email)
                BaseSecureField(textTitle: LoginText.secureField,
                                textField: $viewModel.signInModel.password)
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

#Preview {
    LoginView()
}

extension LoginView {
    
    private var loginText: some View {
        Text("You can access the [linkedin](https://www.linkedin.com/in/kerem-resnenli-47094a28b/) and [github](https://github.com/keremres) of the application developer here.")
            .foregroundStyle(.loginText)
            .tint(.loginTextBlue)
            .padding(.top, 16)
    }
    
    private var signUpButton: some View {
        HStack{
            Text(LoginText.signUpText)
                .foregroundStyle(.loginText)
            NavigationLink(destination: RegisterView()
                .navigationBarBackButtonHidden(true)
            ){
                Text(LoginText.signUp)
                    .foregroundStyle(.loginTextBlue)
            }
        }
        .padding(.top, 16)
    }
    
    private var forgetPasswordButton: some View {
        Text(LoginText.forgotPassword)
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
            Task{
                await viewModel.signIn()
            }
        }, title: LoginText.login)
        .showAlert(alert: $viewModel.alert)
        .padding(.top, 8)
    }
}
