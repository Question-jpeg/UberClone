//
//  LocationSearchView.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import SwiftUI

enum Field {
    case start, destination
}

struct LocationSearchView: View {
    
    @EnvironmentObject var viewModel: LocationsViewModel
    @FocusState var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                DestinationDecorView(variant: .small)
                LocationFieldsView(
                    startLocationText: $viewModel.startLocationText,
                    destinationText: $viewModel.destinationText,
                    focusedField: $focusedField
                )
            }
            .padding(.horizontal, 20)
            
            Button {
                viewModel.setSelectedLocations()
                focusedField = nil
            } label: {
                Text("Go")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .background(.blue)
                    .padding(.horizontal, 50)
                    .padding(.top)
            }
            .disabled(!viewModel.isValid || viewModel.isLoadingRoute)
            .opacity(viewModel.isValid && !viewModel.isLoadingRoute ? 1 : 0.5)
            
            Divider()
                .padding(.top, 10)
            
            List {
                ForEach(viewModel.results, id: \.self) { result in
                    Button {
                        if viewModel.selectedField == .start {
                            viewModel.selectedStartLocation = result
                            focusedField = .destination
                        } else {
                            viewModel.selectedDestination = result
                            focusedField = nil
                        }
                    } label: {
                        LocationResultCell(title: result.title, subtitle: result.subtitle)
                    }
                    .tint(.primary)
                }
            }
        }
    }
}

#Preview {
    LocationSearchView()
        .environmentObject(LocationsViewModel())
}

struct DestinationDecorView: View {
    enum Variant {
        case small, large
    }
    
    let variant: Variant
    
    var pointSize: CGFloat {
        variant == .small ? 6 : 8
    }
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color(.systemGray3))
                .frame(width: pointSize, height: pointSize)
            
            Rectangle()
                .fill(Color(.systemGray3))
                .frame(width: variant == .small ? 1 : 3, height: variant == .small ? 24 : 32)
            
            Rectangle()
                .fill(.primary)
                .frame(width: pointSize, height: pointSize)
        }
    }
}

struct LocationFieldsView: View {
    @Binding var startLocationText: String
    @Binding var destinationText: String
    var focusedField: FocusState<Field?>.Binding
    
    var body: some View {
        VStack {
            Group {
                TextField("Current location", text: $startLocationText)
                    .focused(focusedField, equals: .start)
                TextField("Destination", text: $destinationText)
                    .focused(focusedField, equals: .destination)
            }
            .customSimpleInputStyle()
        }
        .onAppear { focusedField.wrappedValue = .destination }
    }
}

struct LocationResultCell: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.blue)
                .frame(width: 40)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.gray)
            }
            .multilineTextAlignment(.leading)
        }
    }
}
