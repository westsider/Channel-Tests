//
//  Statistics.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/2/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

/*  Class to backtest with optimization  */
class Statistics {
    
    let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
    var profitResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    var winPctResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    var pfResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    var roiResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    func getDistribution( completion: @escaping (Bool) -> Void) {
        
        print("\n\n\t\t\t\t\t\t\t\tStatistical Distribution")
        print("---------------------------------------------------------------------------------------------")
        
        profitResults = Calculations().calcProfit(allTrades: allTradesSortedBtDate)
        Calculations().graphicStats(result: profitResults, type: "Profit")
        winPctResults = Calculations().calcWinPct(allTrades: allTradesSortedBtDate)
        Calculations().graphicStats(result: winPctResults, type: "Win  %")
        pfResults = Calculations().calcPF(allTrades: allTradesSortedBtDate)
        Calculations().graphicStatsFloat(result: pfResults, type: "P Fctr")
        roiResults = Calculations().calcROI(allTrades: allTradesSortedBtDate)
        Calculations().graphicStatsFloat(result: roiResults, type: "ROI   ")
        print("---------------------------------------------------------------------------------------------\n")
        completion(true)
    }
    
    // completion bool when written to realm
    func standardBackTest(debug: Bool, completion: @escaping (Bool) -> Void) {
        
        let dateArray = WklyStats().allEntriesExitsDates(debug: false)
        var portfolio:[String] = []
        var statsArray:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
        var chartArray:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
        var cumulativeProfit:Double = 0.0
        var todaysCost:Double = 0.0
        var winCount:Double = 0.0
        var tradeCount:Double = 0.0
        var winningTrades:[Double] = []
        var losingTrades:[Double] = []
        var roi:[Double] = []
        
        StdBacktest().deleteAll()
        
        for eachDay in dateArray {
            
            var todaysProfit:Double = 0.0
            
            for eachEntry in WklyStats().allEntriesFor(today: eachDay) {
                if portfolio.count < 20 {
                    portfolio.append(eachEntry.ticker)
                    todaysCost += eachEntry.cost
                    tradeCount += 1
                }
            }
            
            for eachExit in WklyStats().allExitsFor(today: eachDay) {
                if portfolio.contains(eachExit.ticker ) {
                    todaysProfit += eachExit.profit
                    todaysCost -= eachExit.cost
                    let portfolioTrimmed = portfolio.filter{$0 != eachExit.ticker}
                    portfolio = portfolioTrimmed
                    if eachExit.profit > 0 {
                        winCount += 1
                        winningTrades.append(eachExit.profit)
                    } else {
                        losingTrades.append(eachExit.profit)
                    }
                    roi.append(eachExit.profit / eachExit.cost)
                    cumulativeProfit += eachExit.profit
                }
            }
            statsArray.append((date: eachDay, cost: todaysCost, profit: todaysProfit, pos: portfolio.count))
            chartArray.append((date: eachDay, cost: todaysCost, profit: cumulativeProfit, pos: portfolio.count))
            StdBacktest().saveDataPoints(date: eachDay, profit: cumulativeProfit, cost: todaysCost, pos: portfolio.count)
        }
        
        if debug {
            print("\nStandard BackTest:")
            for each in statsArray {
                print("\(Utilities().convertToStringNoTimeFrom(date: each.date)) \t \(each.pos) \t cost: $\(Utilities().dollarStr(largeNumber: each.cost)) \t profit: $\(Utilities().dollarStr(largeNumber: each.profit))")
            }
        }
        let arrayOfProfit: [Double] = statsArray.map { (profit: (date:Date, cost:Double, profit:Double, pos:Int)) in
            return profit.profit
        }
        let arrayOfCost: [Double] = statsArray.map { (cost: (date:Date, cost:Double, profit:Double, pos:Int)) in
            return cost.cost
        }
        
        
        
        if var sumCost = arrayOfCost.max() {
            sumCost = sumCost / 2.0
            let winPct = ((winCount / tradeCount) * 100)
            let sum = arrayOfProfit.reduce(0, +)
            let profitFactor = (( winningTrades.sum() / losingTrades.sum() ) * -1)
            let avgRoi = ( sum / sumCost ) * 100
            print("\n\t\t\t\t\t\t\t\tStandard BackTest")
            print("---------------------------------------------------------------------------------------------")
            print("   \(String(format: "%.1f", winPct))% Win \tPF: \(String(format: "%.2f", profitFactor)) \tROI: \(String(format: "%.2f", avgRoi))%\tProfit $\(Utilities().dollarStr(largeNumber: sum)) \t\(Utilities().dollarStr(largeNumber: tradeCount)) Trades \t$\(Utilities().dollarStr(largeNumber: sumCost)) Cost")
            print("---------------------------------------------------------------------------------------------\n")
            print("")
            StatsBacktests().saveDataPoints(group: "STD", winPct: winPct, cumProfit: sum, pf: profitFactor, roi: avgRoi, totalTrades: Int(tradeCount), maxCost: sumCost)
            
        } else {
            print("Warning! could not unwrap Standard BackTest")
        }
        completion(true)
        // push to realm array of profit / cost, statsreturn chartArray
    }
    
    func optimizedBackTest(debug: Bool, completion: @escaping (Bool) -> Void) {
        
        Winners().deleteOld()
        WpctrStats().deleteOld()
        let dateArray = WklyStats().allEntriesExitsDates(debug: false)
        var portfolio:[String] = []
        var statsArray:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
        var chartArray:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
        var cumulativeProfit:Double = 0.0
        var todaysCost:Double = 0.0
        var winCount:Double = 0.0
        var tradeCount:Double = 0.0
        var winningTrades:[Double] = []
        var losingTrades:[Double] = []
        var roi:[Double] = []
        var arraywpctRresults:[(wpctr:Double, profit:Double)] = []
        
        OptBacktest().deleteAll()
        
        for eachDay in dateArray {
            
            var todaysProfit:Double = 0.0
            for eachEntry in WklyStats().allEntriesFor(today: eachDay) {
                if portfolio.count < 20 {
                    // if system is posative
                    if RealmUtil().systemPositive(eachEntry: eachEntry)
                        && MarketCondition().mcValue(forToday: eachDay) >= 0  {
                        portfolio.append(eachEntry.ticker)
                        todaysCost += eachEntry.cost
                        tradeCount += 1
                    }
                }
            }
            
            for eachExit in WklyStats().allExitsFor(today: eachDay) {
                if portfolio.contains(eachExit.ticker ) {
                    todaysProfit += eachExit.profit
                    todaysCost -= eachExit.cost
                    let portfolioTrimmed = portfolio.filter{$0 != eachExit.ticker}
                    portfolio = portfolioTrimmed
                    if eachExit.profit > 0 {
                        winCount += 1
                        winningTrades.append(eachExit.profit)
                    } else {
                        losingTrades.append(eachExit.profit)
                    }
                    roi.append(eachExit.profit / eachExit.cost)
                    cumulativeProfit += eachExit.profit
                    if let thisDate = eachExit.date {
                        Winners().createNew(ticker: eachExit.ticker, date: thisDate)
                    }
                    
                    if let myEntryDate = eachExit.entryDate {
                        let wpcrValue =  WpctR.wpctrValue(forToday: myEntryDate)
                        var profitLmt = eachExit.profit
                        if profitLmt > 180 { profitLmt = 180 }
                        if profitLmt < -180 { profitLmt = -180 }
                        arraywpctRresults.append((wpctr:  wpcrValue, profit: profitLmt))
                        WpctrStats().addToRealm(profit: profitLmt, wpctR: wpcrValue)
                    }
                }
            }

            statsArray.append((date: eachDay, cost: todaysCost, profit: todaysProfit, pos: portfolio.count))
            chartArray.append((date: eachDay, cost: todaysCost, profit: cumulativeProfit, pos: portfolio.count))
            OptBacktest().saveDataPoints(date: eachDay, profit: cumulativeProfit, cost: todaysCost, pos: portfolio.count)
        }
        
        if debug {
            print("\nOptimized BackTest:")
            for each in statsArray {
                print("\(Utilities().convertToStringNoTimeFrom(date: each.date)) \t \(each.pos) \t cost: $\(Utilities().dollarStr(largeNumber: each.cost)) \t profit: $\(Utilities().dollarStr(largeNumber: each.profit))")
            }
        }
        let arrayOfProfit: [Double] = statsArray.map { (profit: (date:Date, cost:Double, profit:Double, pos:Int)) in
            return profit.profit
        }
        let arrayOfCost: [Double] = statsArray.map { (cost: (date:Date, cost:Double, profit:Double, pos:Int)) in
            return cost.cost
        }
        let sumCost = arrayOfCost.max()! / 2
        let sum = arrayOfProfit.reduce(0, +)
        let winPct = (winCount / tradeCount) * 100
        let profitFactor = ( winningTrades.sum() / losingTrades.sum() ) * -1
        let avgRoi = ( sum / sumCost ) * 100
        print("\n\t\t\t\t\t\t\t\tOptimized BackTest")
        print("---------------------------------------------------------------------------------------------\n   \(String(format: "%.1f", winPct))% Win \tPF: \(String(format: "%.2f", profitFactor)) \tROI: \(String(format: "%.2f", avgRoi))%\tProfit $\(Utilities().dollarStr(largeNumber: sum)) \t\(Utilities().dollarStr(largeNumber: tradeCount)) Trades \t$\(Utilities().dollarStr(largeNumber: sumCost)) Cost")
        print("---------------------------------------------------------------------------------------------\n")
        StatsBacktests().saveDataPoints(group: "OPT", winPct: winPct, cumProfit: sum, pf: profitFactor, roi: avgRoi, totalTrades: Int(tradeCount), maxCost: sumCost)
        
        let _ = WpctrStats().getAllStats(debug: true)
       
        completion(true)
    }
    
}

extension Array where Element: Hashable {
    var mode: Element? {
        return self.reduce([Element: Int]()) {
            var counts = $0
            counts[$1] = ($0[$1] ?? 0) + 1
            return counts
            }.max { $0.1 < $1.1 }?.0
    }
}

extension Array where Element: FloatingPoint {
    
    func sum() -> Element {
        return self.reduce(0, +)
    }
    
    func avg() -> Element {
        return self.sum() / Element(self.count)
    }
    
    func std() -> Element {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
        return sqrt(v / (Element(self.count) - 1))
    }
    
}


