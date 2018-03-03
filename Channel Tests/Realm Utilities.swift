//
//  Realm Utilities.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/2/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtil {
    
    func getAllWklyStats(debug:Bool)-> Results<WklyStats> {
        
        let realm = try! Realm()
        let allFiles = realm.objects(WklyStats.self)
            .sorted(byKeyPath: "date", ascending: true)
        if ( debug ) {
            for each in allFiles {
                print("\(each.ticker) \(String(describing: each.date)) p\(each.profit) c\(each.cost) s\(each.stars) cum\(each.cumProfit))")
            }
        }
        return allFiles
    }
    
    func sortOneTicker(ticker:String, debug:Bool)-> Results<WklyStats> {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(WklyStats.self).filter("ticker == %@", id)
            .sorted(byKeyPath: "date", ascending: true)
        if ( debug ) {
            for each in oneSymbol {
                print("\(each.ticker) \(Utilities().convertToStringNoTimeFrom(date: each.date!)) \tp\(each.profit) \tc\(each.cost) \ts\(each.stars) \tcum\(each.cumProfit) \twin%\(each.winPct) \troi\(each.roi)) \tpf\(each.profitFactor))")
            }
        }
        return oneSymbol
    }
    
    func sortTicker(ticker:String,before:Date, debug:Bool)-> Results<WklyStats> {
        let realm = try! Realm()
        let id = ticker
        let oneSymbol = realm.objects(WklyStats.self).filter("ticker == %@", id).filter("date < %@", before)
            .sorted(byKeyPath: "date", ascending: true)
        if ( debug ) {
            for each in oneSymbol {
                print("\(each.ticker) \(Utilities().convertToStringNoTimeFrom(date: each.date!)) \tp\(each.profit) \tc\(each.cost) \ts\(each.stars) \tcum\(each.cumProfit) \twin%\(each.winPct) \troi\(each.roi)) \tpf\(each.profitFactor))")
            }
        }
        return oneSymbol
    }
    
    func setCumProfit(ticker:String) {
        
        let realm = try! Realm()
        let id = ticker
        var cumulatveSum:Double = 0.0
        let oneTicker = sortOneTicker(ticker: ticker, debug: false).filter("ticker == %@", id)
            .sorted(byKeyPath: "date", ascending: true)
        for each in oneTicker {
            cumulatveSum += each.profit
            try! realm.write {
                each.cumProfit = cumulatveSum
            }
            print("\(each.ticker) \t\(Utilities().convertToStringNoTimeFrom(date: each.date!)) \t$\(each.profit) \t$\(each.cost) \t⭐️\(each.stars) \t$$$\t\(cumulatveSum)")
        }
    }
    
    func setCumProfitForAllTickers( dataComplete: @escaping (Bool) -> Void) {
        let portfolio = WklyStats().portfolioDict()
        for each in portfolio {
            print("\(each.key)\t\(each.value)");
            RealmUtil().setCumProfit(ticker: each.key)
        }
        dataComplete(true)
    }
    
}
