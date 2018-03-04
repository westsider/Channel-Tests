//
//  Weekly Stats.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class WklyStats: Object {
    
    @objc dynamic var entryDate:Date?
    @objc dynamic var date:Date?
    @objc dynamic var profit    = 0.00
    @objc dynamic var cumProfit    = 0.00
    
    @objc dynamic var winPct    = 0.00
    @objc dynamic var roi    = 0.00
    @objc dynamic var profitFactor    = 0.00
    
    @objc dynamic var cost      = 0.00
    @objc dynamic var maxCost   = 0.00
    @objc dynamic var taskID    = NSUUID().uuidString
    @objc dynamic var ticker    = ""
    @objc dynamic var stars    = 0
    
    func clearWeekly() {
        let realm = try! Realm()
        let weekly = realm.objects(WklyStats.self)
        try! realm.write {
            realm.delete(weekly)
        }
        print("\nRealm \tWklyStats \tCleared!\n")
    }
    
    func updateCumulativeProfit(date: Date, entryDate:Date, ticker:String, profit: Double, winPct: Double, roi: Double, profitFactor: Double, cost:Double, maxCost:Double) {
        
        let realm = try! Realm()
        let thisWeek = WklyStats()
        thisWeek.date = date
        thisWeek.ticker = ticker
        thisWeek.profit = profit
        thisWeek.winPct = winPct
        thisWeek.roi = roi
        thisWeek.profitFactor = profitFactor
        thisWeek.cost = cost
        thisWeek.maxCost = maxCost
        thisWeek.entryDate = entryDate
        try! realm.write {
            realm.add(thisWeek)
        }
    }
    
    func getWeeklyStatsFromRealm() {
        let realm = try! Realm()
        let weeklyStats = realm.objects(WklyStats.self).sorted(byKeyPath: "date", ascending: true)
        var cumulatveSum:Double = 0.0
        
        print("Weekly Stats from Realm")
        print("date \tticker\tprofit\tcapReq\tcumulative")
        if weeklyStats.count >  1 {
            //let results = sortedByDate
            for each in weeklyStats {
                cumulatveSum += each.profit
                let date = Utilities().convertToStringNoTimeFrom(date: each.date!)
                let profit = Utilities().dollarStr(largeNumber: each.profit)
                let capReq = Utilities().dollarStr(largeNumber: each.cost)
                let cumulative = Utilities().dollarStr(largeNumber: cumulatveSum)
                
                print("\(date)\t\(each.ticker)\t\(profit)\t\(capReq)\t\t\(cumulative)")
            }
        }
    }
    
    func portfolioDict()-> [String:Double] {
        let realm = try! Realm()
        var costDict: [String:Double] = [:]
        let portfolio = realm.objects(WklyStats.self).sorted(byKeyPath: "date", ascending: true)
        for each in portfolio {
            costDict[each.ticker] = each.cumProfit
        }
        return costDict
    }
    
    func allEntriesExitsDates(debug:Bool) -> [Date] {
        
        let realm = try! Realm()
        var answer:[Date] = []
        let allFiles = realm.objects(WklyStats.self).sorted(byKeyPath: "date", ascending: true)
        
        let entry: [Date] = allFiles.map { (entryDate: WklyStats) in
            return entryDate.entryDate!
        }
        
        let exit: [Date] = allFiles.map { (date: WklyStats) in
            return date.date!
        }
        
        let bothArrays = entry + exit
        answer = bothArrays.orderedSet
        answer.sort()
        
        if debug {
            for date in answer {
                print(Utilities().convertToStringNoTimeFrom(date: date))
            }
        }
        return answer
    }
    
    func allEntriesFor(today:Date) -> Results<WklyStats> {
        let realm = try! Realm()
        return  realm.objects(WklyStats.self).filter("entryDate == %@", today)
    }
    
    func allExitsFor(today:Date) -> Results<WklyStats> {
        let realm = try! Realm()
        return  realm.objects(WklyStats.self).filter("date == %@", today)
    }
    
    
}

extension Array where Element: Hashable {
    var orderedSet: Array  {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}







