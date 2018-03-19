//
//  Market Condition.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/19/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class MarketCondition {
    
    //MARK: -  trend as bull, bear, sideways
    func trend(close: Double, sma200: Double, debug:Bool)-> Int {
        let up = sma200 + ( sma200 * 0.02 )
        let dn = sma200 - ( sma200 * 0.02 )
        
        switch close {
        case let x where x > up:
            if debug { print("c\(close) \tsma\(sma200) \tu\(up) \td\(dn) ⬆️") }
            return 1
        case let x where x < dn:
            if debug { print("c\(close) \tsma\(sma200) \tu\(up) \td\(dn)⬇️") }
            return -1
        default:
            if debug { print("c\(close) \tsma\(sma200) \tu\(up) \td\(dn)➡️") }
            return 0
        }
    }
    
    func addMCtoRealm() {
        let spy = Prices().sortOneTicker(ticker: "SPY", debug: false)
        for each in spy {
            let answer = trend(close: each.close, sma200: each.sma200, debug: false)
            Prices().addMC(ticker: each.ticker, date: each.dateString, mc: answer, debug: false)
        }
        print("\nMarket Condition Calculation Complete\n")
    }
    
    func mcValue(forToday:Date)->Int {
        
        var answer = 0
        let realm = try! Realm()
        if let oneSymbol = realm.objects(Prices.self).filter("ticker == %@", "SPY").filter("date == %@", forToday).last {
            answer = oneSymbol.marketComdition
        }
        return answer
    }
}
