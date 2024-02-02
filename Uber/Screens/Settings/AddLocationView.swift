//
//  AddHomeView.swift
//  Uber
//
//  Created by Игорь Михайлов on 14.01.2024.
//

import SwiftUI

struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    let locationType: LocationType
    
    var body: some View {
        VStack {
            TextField("Enter an address here", text: $viewModel.locationText)
                .customSimpleInputStyle()
                .padding([.leading, .top, .trailing])
            
            List {
                ForEach(viewModel.results, id: \.self) { result in
                    Button {
                        viewModel.setLocation(result: result, forType: locationType)
                        viewModel.locationText = ""
                        dismiss()
                    } label: {
                        LocationResultCell(title: result.title, subtitle: result.subtitle)
                    }
                }
            }
        }
        .navigationTitle("Add \(locationType.title) Address")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .tint(.primary)
    }
}

#Preview {
    NavigationStack {
        let authModel = AuthViewModel()
        AddLocationView(viewModel: SettingsViewModel(authModel: authModel), locationType: .home)
            .environmentObject(authModel)
    }
}
