//
//  RideRequestView.swift
//  Uber
//
//  Created by Игорь Михайлов on 09.01.2024.
//

import SwiftUI

struct RideRequestView: View {
    @State private var selectedRideType = RideType.uberX
    let routeInfo: RouteInfo
    let requestTrip: (RideType) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HandleView()
                .padding(.vertical, 15)
            
            HStack(spacing: 20) {
                DestinationDecorView(variant: .large)
                VStack(spacing: 30) {
                    RideLocationCell(
                        locationText: routeInfo.start.isCurrent ? "Current Location" : routeInfo.start.title,
                        timeText: routeInfo.pickUpTime,
                        variant: .start
                    )
                    RideLocationCell(
                        locationText: routeInfo.destination.title,
                        timeText: routeInfo.dropOffTime,
                        variant: .destination
                    )
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 20)
            
            CarSelectionView(
                selectedRideType: $selectedRideType,
                distanceInMeters: routeInfo.distanceInMeters
            )
            
            PaymentLinkView()
                .padding(.top)
            
            Button {
                requestTrip(selectedRideType)
            } label: {
                Text("CONFIRM RIDE")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .tint(.white)
            .padding()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        RideRequestView(routeInfo: MockData.routeInfo, requestTrip: { _ in })
    }
}

struct RideLocationCell: View {
    enum Variant {
        case start, destination
    }
    
    let locationText: String
    let timeText: String
    let variant: Variant
    
    var body: some View {
        HStack {
            Text(locationText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(variant == .start ? .gray : .primary)
            
            Spacer()
            
            Text(timeText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)
        }
    }
}

struct CarSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedRideType: RideType
    
    let distanceInMeters: Double
    
    func calculatePrice(forRideType rideType: RideType) -> Double {
        rideType.computePrice(forDistanceInMeters: distanceInMeters)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("SUGGESTED RIDES")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.leading)
                .foregroundStyle(.gray)
                .padding(.bottom, 10)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(RideType.allCases) { rideType in
                        Button {
                            selectedRideType = rideType
                        } label: {
                            VStack(alignment: .leading) {
                                rideType.image
                                    .resizable()
                                    .scaledToFit()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rideType.description)
                                    Text(calculatePrice(forRideType: rideType).toCurrency())
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(8)
                                .padding(.horizontal, 5)
                                .foregroundStyle((colorScheme == .light && rideType != selectedRideType) ? .black : .white)
                            }
                            .frame(width: 110, height: 140)
                            .background(Color(rideType == selectedRideType ? .systemBlue : .systemGray5))
                            .scaleEffect(rideType == selectedRideType ? 1.1 : 1)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .animation(.snappy, value: selectedRideType)
                        }
                        .tint(.primary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct PaymentLinkView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("Visa")
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(6)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.leading)
            
            Text("**** 1234")
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .padding()
        }
        .frame(height: 50)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}
