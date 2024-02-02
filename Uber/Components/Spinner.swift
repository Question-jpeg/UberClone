//
//  Spinner.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import SwiftUI

struct Spinner: View {
    
    let size: CGFloat
    
    @State private var animation = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(style: StrokeStyle(lineWidth: size*0.1, lineCap: .round))
                .fill(.blue.opacity(0.85))
                .frame(width: size)
                .rotationEffect(.degrees(360 * animation))
            
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(style: StrokeStyle(lineWidth: size*0.1, lineCap: .round))
                
                .frame(width: size*0.7)
                .rotationEffect(.degrees(360 * animation * 3))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                animation = 1
            }
        }
    }
}

#Preview {
    Spinner(size: 100)
}
