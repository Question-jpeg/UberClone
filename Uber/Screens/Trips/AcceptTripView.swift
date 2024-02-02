//
//  AcceptTripView.swift
//  Uber
//
//  Created by Игорь Михайлов on 17.01.2024.
//

import SwiftUI
import MapKit


struct AcceptTripView: View {
    @State private var cameraPosition: MapCameraPosition
    let trip: Trip
    let pinCoordinate: CLLocationCoordinate2D
    let updateTripState: (TripState) -> Void
    
    init(trip: Trip, updateTripState: @escaping (TripState) -> Void) {
        self.trip = trip
        self.updateTripState = updateTripState
        
        pinCoordinate = CLLocationCoordinate2D(
            latitude: trip.pickupLocation.coordinates.latitude,
            longitude: trip.pickupLocation.coordinates.longitude
        )
        let region = MKCoordinateRegion(
            center: pinCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.025,
                longitudeDelta: 0.025
            )
        )
        
        _cameraPosition = State(initialValue: MapCameraPosition.region(region))
    }
    
    var body: some View {
        VStack {
            HandleView()
                .padding(.top, 15)
            
            VStack(spacing: 20) {
                AcceptHeadingView(deliveryTime: trip.deliveryTime)
                Divider()
                HStack {
                    PassengerInfoView(name: trip.passenger.name)
                    Spacer()
                    EarningsView(cost: trip.cost)
                }
                Divider()
                AddressInfoView(cameraPosition: $cameraPosition, trip: trip, pinCoordinate: pinCoordinate)
                Divider()
                HStack {
                    Button {
                        updateTripState(.rejected)
                    } label: {
                        Text("Reject")
                            .frame(width: 150, height: 50)
                            .background(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                    Button {
                        updateTripState(.accepted)
                    } label: {
                        Text("Accept")
                            .frame(width: 150, height: 50)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        Spacer()
        AcceptTripView(trip: MockData.trip, updateTripState: { _ in })
    }
}

struct AcceptHeadingView: View {
    
    let deliveryTime: Int
    
    var body: some View {
        HStack {
            Text("Would you like to pickup this passenger?")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            VStack {
                Text(deliveryTime.formatted())
                
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

struct PassengerInfoView: View {
    let name: String
    
    var body: some View {
        HStack {
            Image(.maleProfilePhoto2)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(name)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)
                    
                    Text("4.8")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            
            
        }
    }
}

struct AddressInfoView: View {
    @Binding var cameraPosition: MapCameraPosition
    let trip: Trip
    let pinCoordinate: CLLocationCoordinate2D
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(trip.pickupLocation.title)
                        .font(.headline)
                    
                    Text(trip.pickupLocation.address)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                VStack {
                    Text(trip.deliveryDistance.toDistance())
                        .font(.headline)
                    Text("mi")
                        .font(.subheadline)
                        .foregroundStyle(.gray )
                }
            }
            
            Map(position: $cameraPosition) {
                Marker("", coordinate: pinCoordinate)
            }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.4), radius: 10)
                .padding(.top)
        }
    }
}

struct EarningsView: View {
    
    let cost: Double
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Earnings")
            
            Text(cost.toCurrency())
                .font(.system(size: 24, weight: .semibold))
        }
    }
}
