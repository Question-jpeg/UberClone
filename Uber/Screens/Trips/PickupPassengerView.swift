//
//  PickupPassengerView.swift
//  Uber
//
//  Created by Игорь Михайлов on 18.01.2024.
//

import SwiftUI

struct PickupPassengerView: View {
    
    let trip: Trip
    let cancel: () -> Void
    
    var body: some View {
        VStack {
            HandleView()
                .padding(.top, 10)
            
            VStack(spacing: 15) {
                PickupHeaderView(trip: trip)
                Divider()
                HStack {
                    PassengerInfoView(name: trip.passenger.name)
                    Spacer()
                    EarningsView(cost: trip.cost)
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
        }
        .padding(.horizontal)
    }
}

#Preview {
    PickupPassengerView(trip: MockData.trip, cancel: {})
}

struct PickupHeaderView: View {
    
    let trip: Trip
    
    var body: some View {
        HStack {
            Text("Pickup \(trip.passenger.name) at \(trip.pickupLocation.title)")
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
