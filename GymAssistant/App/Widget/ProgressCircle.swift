//
//  ProgressCircle.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 9.08.2024.
//

import SwiftUI

struct ProgressCircle: View {
    
    @Binding var progress: Int
    var goal: Int
    var color: Color
    private let width: CGFloat = 10
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(color.opacity(0.3), lineWidth: width)
            Circle()
                .trim(from: 0, to: CGFloat(progress) / CGFloat(goal))
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
        }.padding(.all, 5)
    }
}

#Preview {
    ProgressCircle(progress: .constant(100), goal: 150, color: .blue)
}
