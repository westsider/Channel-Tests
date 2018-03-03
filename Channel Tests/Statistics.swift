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

        profitResults = Calculations().calcProfit(allTrades: allTradesSortedBtDate)
        Calculations().graphicStats(result: profitResults, type: "Profit")
        winPctResults = Calculations().calcWinPct(allTrades: allTradesSortedBtDate)
        Calculations().graphicStats(result: winPctResults, type: "Win  %")
        pfResults = Calculations().calcPF(allTrades: allTradesSortedBtDate)
        Calculations().graphicStats(result: pfResults, type: "P Fctr")
        roiResults = Calculations().calcROI(allTrades: allTradesSortedBtDate)
        Calculations().graphicStatsFloat(result: roiResults, type: "ROI   ")
        runBackTestAllTrades()
    }
    
    func runBackTestAllTrades() {
        
        var cumProfit:Double = 0.0
        var winCount:Double = 0.0
        var tradeCount:Double = 0.0
        var pf:[Double] = []
        var roi:Double = 0.0
        
        for eachTrade in allTradesSortedBtDate {
            
            let earlierDate = RealmUtil().sortTicker(ticker: eachTrade.ticker, before: eachTrade.date!, debug: false)
            
            if earlierDate.count > 0 {

            cumProfit += eachTrade.profit
            if eachTrade.profit >= 0 {
                winCount += 1
            }
            tradeCount += 1
            pf.append(eachTrade.profitFactor) //+= eachTrade.profitFactor // this is cumulative
            roi += eachTrade.roi
            }
        }
        
        let winPct = (winCount / tradeCount) * 100
        let avgPF = pf.last  //pf / tradeCount
        
        print("\nStandard BackTest\nProfit: $\(Utilities().dollarStr(largeNumber: cumProfit)) \t \(String(format: "%.1f", winPct))% Win \t PF: \(String(format: "%.1f", avgPF!)) \t ROI: \(String(format: "%.1f", roi)) \t \(tradeCount) trades\n")
        runFilteredBackTest(debug: false)
    }

    // [ ] 20 max positions
    // [ ] add chart
    // [ ] use steppers on main UI for profit, winPct, pf, roi
    /*
     Standard BackTest
     Profit: $60,555      61.7% Win      PF: 2.2      ROI: 20.6      4835.0 trades
     
     Profit          -1999  ----  -99 <<< 15 [0] >>> 129 ---- 4999
     Win  %          0  ----  41 <<< 60 [60] >>> 78 ---- 93
     P Fctr          0  ----  -1 <<< 2 [1] >>> 7 ---- 48
     ROI             -100.00  ----  -4.237 <<< 0.524 [1.240] >>> 5.285 ---- 250.000
     
     pastTrades.avgProfit > ( 1 )
     && eachTrade.winPct > ( 59 )
     && pastTrades.avgPF > ( 0.3 )
     && pastTrades.avgROI > (0.001)
     
     Optimized BackTest
     Profit: $77,462      70.2% Win      PF: 2.2      ROI: 26.517      3180.0 trades
     */
    
    func runFilteredBackTest(debug:Bool) {
        
        var cumProfit:Double = 0.0
        var winCount:Double = 0.0
        var tradeCount:Double = 0.0
        var winningTrades:[Double] = []
        var losingTrades:[Double] = []
        var roi:[Double] = []
        
        //MARK: - Limit to 20 positions
        
        for eachTrade in allTradesSortedBtDate {
           
            let pastTrades = RealmUtil().getHistory(forTicker: eachTrade.ticker, before: eachTrade.date!, debug: false) // else {
          
            if pastTrades.avgProfit > ( 1 )
                && eachTrade.winPct > ( 59 )
                && pastTrades.avgPF > ( 0.3 )
                && pastTrades.avgROI > (0.001)
            {
                if debug { print("\t Adding \(eachTrade.ticker) \(eachTrade.profit) because \(pastTrades.avgProfit) > \(0 )") }
                cumProfit += eachTrade.profit
                if eachTrade.profit >= 0 {
                    winCount += 1
                    winningTrades.append(eachTrade.profit)
                } else {
                    losingTrades.append(eachTrade.profit)
                }
                tradeCount += 1
                roi.append(eachTrade.profit / eachTrade.cost)
            } else {
                if debug { print("\t Skip \(eachTrade.profit)") }
            }
        }
        let winPct = (winCount / tradeCount) * 100
        let profitFactor = ( winningTrades.sum() / losingTrades.sum() ) * -1
        let avgRoi = roi.sum()
        
        print("\nOptimized BackTest\nProfit: $\(Utilities().dollarStr(largeNumber: cumProfit)) \t \(String(format: "%.1f", winPct))% Win \t PF: \(String(format: "%.1f", profitFactor)) \t ROI: \(String(format: "%.3f", avgRoi)) \t \(tradeCount) trades\n")
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


