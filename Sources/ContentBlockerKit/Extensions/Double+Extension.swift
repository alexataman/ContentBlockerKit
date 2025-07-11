//
//  Double+Extension.swift
//  ContentBlockerKit
//
//  Created by Alex Atamanskyi on 11.07.2025.
//
import Foundation

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
