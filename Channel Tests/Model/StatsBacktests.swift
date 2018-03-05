//
//  StatsBacktests.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/5/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

//final results for UI, this is the result of the backtest here in ios
class StatsBacktests: Object {
    
    @objc dynamic var group    = "std or opt"
    @objc dynamic var winPct    = 0.00
    @objc dynamic var cumProfit    = 0.00
    @objc dynamic var profitFactor    = 0.00
    @objc dynamic var roi    = 0.00
    @objc dynamic var totalTrades    = 0
    @objc dynamic var cost      = 0.00
    @objc dynamic var maxCost   = 0.00
    @objc dynamic var taskID    = NSUUID().uuidString
    
    // func to populate
    
    // func to set UI
}

// arrays for chart
class StdBacktest: Object {
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var cost    = 0.00
    @objc dynamic var positions    = 0
    @objc dynamic var taskID    = NSUUID().uuidString
    
    func saveDataPoints(date:Date, profit:Double, cost:Double, pos:Int) {
        let realm = try! Realm()
        let stdBackTest = StdBacktest()
        stdBackTest.date = date
        stdBackTest.profit = profit
        stdBackTest.cost = cost
        stdBackTest.positions = pos
        try! realm.write {
            realm.add(stdBackTest)
        }
    }
    
    // func to populate
    func populateProfitChart() -> Zip2Sequence<[Date], [Double]> {
        
        let realm = try! Realm()
        let allFiles = realm.objects(StdBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: StdBacktest) in return date.date! }
        let profit: [Double] = allFiles.map { (profit: StdBacktest) in return profit.profit }
        return  zip(date, profit)
    }
    
    // func to populate
    func populateCosttChart() -> Zip2Sequence<[Date], [Double]> {
        
        let realm = try! Realm()
        let allFiles = realm.objects(StdBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: StdBacktest) in return date.date! }
        let cost: [Double] = allFiles.map { (cost: StdBacktest) in return cost.cost }
        return  zip(date, cost)
    }
}

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
    
    // func to populate
    func populateProfitChart() -> Zip2Sequence<[Date], [Double]> {
        
        let realm = try! Realm()
        let allFiles = realm.objects(OptBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: OptBacktest) in return date.date! }
        let profit: [Double] = allFiles.map { (profit: OptBacktest) in return profit.profit }
        return  zip(date, profit)
    }
    
    // func to populate
    func populateCosttChart() -> Zip2Sequence<[Date], [Double]> {
        
        let realm = try! Realm()
        let allFiles = realm.objects(OptBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: OptBacktest) in return date.date! }
        let cost: [Double] = allFiles.map { (cost: OptBacktest) in return cost.cost }
        return  zip(date, cost)
    }
}
