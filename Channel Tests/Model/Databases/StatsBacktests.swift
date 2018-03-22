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
    @objc dynamic var maxCost   = 0.00
    @objc dynamic var taskID    = NSUUID().uuidString
    
    // func to populate
    func saveDataPoints(group:String, winPct:Double, cumProfit:Double, pf:Double, roi:Double, totalTrades:Int, maxCost:Double) {
        
        delete(group: group)
        let realm = try! Realm()
        let statsBacktests = StatsBacktests()
        statsBacktests.group = group
        statsBacktests.winPct = winPct
        statsBacktests.cumProfit = cumProfit
        statsBacktests.profitFactor = pf
        statsBacktests.roi = roi
        statsBacktests.totalTrades = totalTrades
        statsBacktests.maxCost = maxCost
        try! realm.write {
            realm.add(statsBacktests)
        }
    }
    
    func delete(group:String) {
        let realm = try! Realm()
        let clearIt = realm.objects(StatsBacktests.self).filter("group == %@", group)
        try! realm.write {
            realm.delete(clearIt)
        }
        print("\nRealm \tStatsBacktests group \(group) \tCleared!\n")
    }
    func populateUI(group:String) -> StatsBacktests? {
        let realm = try! Realm()
        let allFiles = realm.objects(StatsBacktests.self).filter("group == %@", group).last
        return allFiles
    }
    
    func check() {
        let realm = try! Realm()
        let allFiles = realm.objects(StatsBacktests.self)
        for uiText in allFiles {
            print("Win \(uiText.winPct) \tpf \(uiText.profitFactor) \troi \(uiText.roi) \tProfit\(uiText.cumProfit) \ttrades \(uiText.totalTrades) \t cost\(uiText.maxCost)" )
        }
    }
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
    
    func deleteAll() {
        let realm = try! Realm()
        let clearIt = realm.objects(StdBacktest.self)
        try! realm.write {
            realm.delete(clearIt)
        }
        print("\nRealm \tStdBacktest \tCleared!\n")
    }
    
    // func to populate
    func populateProfitChart() -> [(date:Date, profit:Double)] {
        
        let realm = try! Realm()
        let allFiles = realm.objects(StdBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: StdBacktest) in return date.date! }
        let profit: [Double] = allFiles.map { (profit: StdBacktest) in return profit.profit }
        let zipped = Array(zip(date, profit))
        return  zipped
    }
    

    // func to populate
    func populateCostChart() -> [(date:Date, cost:Double)] {
        
        let realm = try! Realm()
        let allFiles = realm.objects(StdBacktest.self).sorted(byKeyPath: "date", ascending: true)
        let date: [Date] = allFiles.map { (date: StdBacktest) in return date.date! }
        let cost: [Double] = allFiles.map { (cost: StdBacktest) in return cost.cost }
        let zipped = Array(zip(date, cost))
        return  zipped
    }
}


