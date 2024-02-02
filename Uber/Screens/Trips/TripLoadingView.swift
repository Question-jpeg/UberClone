//
//  TripLoadingView.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import SwiftUI

struct TripLoadingView: View {
    var body: some View {
        VStack {
            HandleView()
                .padding(.vertical, 10)
            
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Connecting you to a driver")
                        .font(.headline)
                    
                    Text("It may take some time")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                Spinner(size: 50)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TripLoadingView()
}
