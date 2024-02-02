//
//  DoubleExt.swift
//  Uber
//
//  Created by Игорь Михайлов on 11.01.2024.
//

import Foundation

extension Double {
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    private var distanceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    func toCurrency() -> String {
        currencyFormatter.string(for: self) ?? ""
    }
    
    func toDistance() -> String {
        return distanceFormatter.string(for: self) ?? ""
    }
}
