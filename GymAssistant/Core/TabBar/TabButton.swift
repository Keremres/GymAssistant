//
//  TabButton.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 27.07.2024.
//

import SwiftUI

struct TabButton: View {
    var title : TabBarName
    var image : TabBarImage
    
    @Binding var selected : TabBarName
    
    var body: some View {
        Button(action: {
            withAnimation(.spring) {
                selected = title
            }
        }){
            HStack{
                Image(systemName: image.rawValue).resizable().foregroundStyle(.tabBar).frame(width: 25,height: 25)
                if selected == title{
                    Text(title.rawValue).bold().tint(.tabBar)
                }
            }.padding(.horizontal).padding(.vertical,10).background(.tabBar.opacity(selected == title ? 0.3 : 0)).clipShape(Capsule())
        }
    }
}