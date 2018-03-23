//
//  Optimised Backtest.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/22/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class OptBacktest: Object {
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var cost    = 0.00
    @objc dynamic var positions    = 0
    @objc dynamic var taskID    = NSUUID().uuidString
    
    func saveDataPoints(date:Date, profit:Double, cost:Double, pos:Int) {
        
        let realm = try! Realm()
        let optBacktest = OptBacktest()
        optBacktest.date = date
        optBacktest.profit = profit
        optBacktest.cost = cost
        optBacktest.positions = pos
        try! realm.write {
            realm.add(optBacktest)
        }
    }
    
    func deleteAll() {
        let realm = try! Realm()
        let clearIt = realm.objects(OptBacktest.self)
        try! realm.write {
            realm.delete(clearIt)
        }
        print("\nRealm \tOptBacktest \tCleared!\n")
    }
    
    // func to populate
    func populateProfitChart() -> [(date:Date, profit:Double)] {
        
        let realm = try! Realm()
        let allFiles = realm.objects(OptBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: OptBacktest) in return date.date! }
        let profit: [Double] = allFiles.map { (profit: OptBacktest) in return profit.profit }
        let zipped = Array(zip(date, profit))
        return  zipped
    }
    
    // func to populate
    func populateCostChart() ->  [(date:Date, cost:Double)] {
        
        let realm = try! Realm()
        let allFiles = realm.objects(OptBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: OptBacktest) in return date.date! }
        let cost: [Double] = allFiles.map { (cost: OptBacktest) in return cost.cost }
        let zipped = Array(zip(date, cost))
        return  zipped
    }
    
    func findMaxDrawDown(debug:Bool)-> String {
        
        var lastprofitPeak = 0.0
        var drawDown = 0.0
        var maxDrawDown = 0.0
        var profitPeakDate:Date?
        var maxDrawDownDate:Date?
        var profitPeakDates:[Date] = []
        
        let realm = try! Realm()
        let portfolio = realm.objects(OptBacktest.self).sorted(byKeyPath: "date", ascending: true)
        for each in portfolio {
            if each.profit > lastprofitPeak {
                lastprofitPeak = each.profit
                profitPeakDate = each.date
                profitPeakDates.append(each.date!)
            }
            
            drawDown = lastprofitPeak - each.profit
            if drawDown > maxDrawDown {
                maxDrawDown = drawDown
                maxDrawDownDate = each.date
            }
        }
        var message = findLongestDrawdown(profitPeakDates: profitPeakDates, debug: debug)
        message += "Max DD $\(Utilities().dollarStr(largeNumber: maxDrawDown)) "
        if debug { print(message) }
        return message
    }
    
    func findLongestDrawdown(profitPeakDates:[Date], debug:Bool)->String {
        
        var longestDD:Int = 0
        var dateOfDD:Date = Date()
        for (index, thisDate) in profitPeakDates.enumerated() {
            if index >= 2 {
                let date1 = profitPeakDates[index - 1]
                let date2 = profitPeakDates[index]
                let days = Utilities().calcuateDaysBetweenTwoDates(start: date1, end: date2, debug: false)
                if days > longestDD {
                    longestDD = days
                    dateOfDD = thisDate
                }
            } 
        }
        let message = "\(longestDD) days before new high and ended on \(Utilities().convertToStringNoTimeFrom(date: dateOfDD)) "
        if debug { print(message) }
        return message
    }
}




















