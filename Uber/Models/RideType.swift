//
//  RideType.swift
//  Uber
//
//  Created by Игорь Михайлов on 10.01.2024.
//

import SwiftUI

enum RideType: Int, CaseIterable, Identifiable {
    case uberX, black, uberXL
    
    var id: Int { rawValue }
    
    var description: String {
        switch self {
        case .uberX:
            return "UberX"
        case .black:
            return "UberBlack"
        case .uberXL:
            return "UberXL"
        }
    }
    
    var image: Image {
        switch self {
        case .uberX:
            return Image(.uberX)
        case .black:
            return Image(.uberBlack)
        case .uberXL:
            return Image(.uberX)
        }
    }
    
    var baseFare: Double {
        switch self {
        case .uberX:
            return 1
        case .black:
            return 5
        case .uberXL:
            return 2
        }
    }
    
    private var multiplyFactor: Double {
        switch self {
        case .uberX:
            return 0.1875
        case .black:
            return 0.5
        case .uberXL:
            return 0.3
        }
    }
    
    func computePrice(forDistanceInMeters distanceMeters: Double) -> Double {
        let distanceMiles = distanceMeters / 1600
        
        return distanceMiles * multiplyFactor + baseFare
    }
}
