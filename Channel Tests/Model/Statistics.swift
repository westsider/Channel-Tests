//
//  Statistics.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/2/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Statistics {
    
    let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
    
    var profitResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    // auto select Low = 11 result.avg - result.std)
    var winPctResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    // auto select Low = 64 result.avg - result.std)
    var pfResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    // auto select mode = 1
    var roiResults:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    // auto select Low 0.3 result.avg - result.std)
    // multiply roi * 100 to display human readable in UI
    
    func getDistribution() {
        
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
    }
    
    func standardBackTest(debug: Bool) -> [(date:Date, cost:Double, profit:Double, pos: Int)]  {
        
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
        let sumCost = arrayOfCost.max()
        let sum = arrayOfProfit.reduce(0, +)
        let winPct = (winCount / tradeCount) * 100
        let profitFactor = ( winningTrades.sum() / losingTrades.sum() ) * -1
        let avgRoi = roi.sum()
        print("\n\t\t\t\t\t\t\t\tStandard BackTest")
        print("---------------------------------------------------------------------------------------------\n   \(String(format: "%.1f", winPct))% Win \tPF: \(String(format: "%.2f", profitFactor)) \tROI: \(String(format: "%.2f", avgRoi))%\tProfit $\(Utilities().dollarStr(largeNumber: sum)) \t\(Utilities().dollarStr(largeNumber: tradeCount)) Trades \t$\(Utilities().dollarStr(largeNumber: sumCost!)) Cost")
        print("---------------------------------------------------------------------------------------------\n")
        print("")
        return chartArray
    }
    
    func optimizedBackTest(debug: Bool) -> [(date:Date, cost:Double, profit:Double, pos: Int)]  {
        
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
        
        for eachDay in dateArray {
            
            var todaysProfit:Double = 0.0
            
            for eachEntry in WklyStats().allEntriesFor(today: eachDay) {
                if portfolio.count < 20 {
                    // if system is posative
                    if RealmUtil().systemPositive(eachEntry: eachEntry) {
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
                }
            }
            statsArray.append((date: eachDay, cost: todaysCost, profit: todaysProfit, pos: portfolio.count))
            chartArray.append((date: eachDay, cost: todaysCost, profit: cumulativeProfit, pos: portfolio.count))
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
        return chartArray
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


