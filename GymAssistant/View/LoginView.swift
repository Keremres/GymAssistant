//
//  LoginView.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    var body: some View {
        NavigationStack{
            VStack{
                BaseTextField(textTitle: LoginText.TextField, textField: $viewModel.email)
                
                BaseSecureField(textTitle: LoginText.SecureField, textField: $viewModel.password).padding(Edge.Set.top,16)
                
                Text("Forgot your password?")
                    .padding(.top, CGFloat(8))
                    .foregroundStyle(.loginTextBlue)
                    .onTapGesture {
                        withAnimation{
                            viewModel.showForgotPassword = true
                        }
                    }
                
                BaseButton(onTab: {
                    Task{
                        try await viewModel.signIn()
                    }
                }, title: LoginText.Login).padding(Edge.Set.top,8)
                    .alert(viewModel.errorTitle, isPresented: $viewModel.error){
                        Button("Cancel", role: .cancel, action: {
                            viewModel.errorClear()
                        })
                    }message: {
                        Text(viewModel.errorMessage)
                    }
                
                HStack{
                    Text("Don't have an account? ").padding(Edge.Set.top,16).foregroundStyle(.loginText)
                    NavigationLink(destination: RegisterView()
                        .navigationBarBackButtonHidden(true)
                    ){
                        Text("Sign up.").padding(Edge.Set.top,16).foregroundStyle(.loginTextBlue)
                    }
                }
                Text("You can access the [linkedin](https://www.linkedin.com/in/kerem-resnenli-47094a28b/) and [github](https://github.com/keremres) of the application developer here.").padding(Edge.Set.top,16).foregroundStyle(.loginText).tint(.loginTextBlue)
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
