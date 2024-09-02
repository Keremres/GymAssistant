//
//  BaseButton.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct BaseButton: View {
    var onTab:() -> Void
    var title: String
    var body: some View {
        Button{
            onTab()
        }label:{
            HStack{
                Text(title).foregroundColor(.tabBarText).font(.title2)
            }
        }.tint(.tabBar).buttonStyle(.borderedProminent).buttonBorderShape(.roundedRectangle(radius: 10)).controlSize(.large).shadow(radius: 10)
    }
}
