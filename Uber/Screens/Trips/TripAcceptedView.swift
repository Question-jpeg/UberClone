//
//  TripAcceptedView.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import SwiftUI

struct TripAcceptedView: View {
    
    let trip: Trip
    let cancel: () -> Void
    
    var body: some View {
        VStack {
            HandleView()
                .padding(.vertical, 10)
            
            VStack(spacing: 15) {
                AcceptedTripHeaderView(trip: trip)
                
                Divider()
                
                HStack(alignment: .bottom) {
                    PassengerInfoView(name: trip.driver.name)
                    
                    Spacer()
                    
                    CarInfoView()
                }
                
                Divider()
                
                Button {
                    cancel()
                } label: {
                    Text("Cancel Trip")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .foregroundStyle(.white)
                        .background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TripAcceptedView(trip: MockData.trip, cancel: {})
}

struct AcceptedTripHeaderView: View {
    
    let trip: Trip
    
    var body: some View {
        HStack {
            Text("Meet your driver at \(trip.pickupLocation.title)")
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.trailing)
            
            Spacer()
            
            VStack {
                Text(trip.deliveryTime.formatted())
                
                Text("min")
            }
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct CarInfoView: View {
    var body: some View {
        VStack {
            Image(.uberX)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 64)
            
            HStack {
                Text("Mercedes S")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                Text("5G4K08")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}
