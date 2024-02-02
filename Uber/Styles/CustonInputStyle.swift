//
//  CustonInputStyle.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import SwiftUI

extension View {
    func customInputStyle(title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.semibold)
                .font(.footnote)
            
            self
            
            Rectangle()
                .fill(Color(.darkGray))
                .frame(height: 0.7)
        }
        .preferredColorScheme(.dark)
    }
    
    func customSimpleInputStyle() -> some View {
        self
            .padding()
            .frame(height: 32)
            .background(Color(.systemGray5))
    }
}
