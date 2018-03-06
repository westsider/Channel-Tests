//
//  Market Hours.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/5/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//
import UIKit
import Foundation

class MarketHours {
    
    func isMarketOpen() -> String {
        
        var greeting = String()
        
        //date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        // Get current time and format it to compare
        var currentTime = Date()
        let currentTimeStr = dateFormatter.string(from: currentTime)
        currentTime = dateFormatter.date(from: currentTimeStr)!
        
        //Times array
        let startTimes = ["6:30 AM", //Open
            "1:00 PM" //Close
        ]
        
        let openingBell = 0
        let closingBell = 1
        
        var dateTimes = [Date]()
        
        //create an array with the desired times
        for i in 0..<startTimes.count{
            let dateTime = dateFormatter.date(from: startTimes[i])
            print(dateTime!)
            dateTimes.append(dateTime!)
        }
        
        if currentTime >= dateTimes[openingBell] && currentTime < dateTimes[closingBell]   {
            greeting = "Market Open"
        }
        if currentTime >= dateTimes[closingBell]   {
            greeting = "Market Closed"
        }
        
        return greeting
    }
    
    func currentTimeText() -> String {

        //date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        // Get current time and format it to compare
        let currentTime = Date()
        let currentTimeStr = dateFormatter.string(from: currentTime)
        return currentTimeStr
    }
}
