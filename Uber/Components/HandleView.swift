//
//  HandleView.swift
//  Uber
//
//  Created by Игорь Михайлов on 17.01.2024.
//

import SwiftUI

struct HandleView: View {
    var body: some View {
        Capsule()
            .foregroundStyle(Color(.systemGray5))
            .frame(width: 48, height: 6)
            .frame(maxWidth: .infinity)            
    }
}

#Preview {
    HandleView()
}
