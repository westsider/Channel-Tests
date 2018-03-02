//
//  Utilities.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Utilities {
    let formatter = DateFormatter()
    let today = Date()
    
    func convertToDateFrom(string: String, debug: Bool)-> Date {
        if ( debug ) { print("\ndate from is string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "yyyy/MM/dd"
        let date:Date = formatter.date(from: dateS)!
        if ( debug ) { print("Convertion to Date: \(date)\n") }
        return date
    }
    
    func convertToDateFromNT(string: String, debug: Bool)-> Date? {
        if ( debug ) { print("\ndate from is string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "MM/dd/yyyy"
        if let date:Date = formatter.date(from: dateS) {
            if ( debug ) { print("Convertion to Date: \(date)\n") }
            return date
        } else {
            if ( debug ) { print("Convertion to Date HAS FAILED!!!\n") }
            return nil
        }
        
    }
    
    func convertToStringFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    func convertToStringNoTimeFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}
