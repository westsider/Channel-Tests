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
    
    // display these in UI
    // turn these into IB Buttons so I can test quickly
    
    // loop though all trades and only take trades that pass the star filter and 20 max.
    
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

        profitResults = calcProfit(allTrades: allTradesSortedBtDate)
        graphicStats(result: profitResults, type: "Profit")
        

        winPctResults = calcWinPct(allTrades: allTradesSortedBtDate)
        graphicStats(result: winPctResults, type: "Win  %")
        

        pfResults = calcPF(allTrades: allTradesSortedBtDate)
        graphicStats(result: pfResults, type: "P Fctr")
        
      
        roiResults = calcROI(allTrades: allTradesSortedBtDate)
        graphicStatsFloat(result: roiResults, type: "ROI   ")
        
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
        runFilteredBackTest()
        /*
         Profit          -229  ----  -63 <<< 11 [40] >>> 86 ---- 215
         
         
         Win  %          0  ----  47 <<< 64 [60] >>> 82 ---- 92
         
         
         P Fctr          0  ----  -1 <<< 3 [1] >>> 8 ---- 30
         
         
         ROI             -8.54  ----  -2.082 <<< 0.377 [0.610] >>> 2.836 ---- 6.700
         
         
         Standard BackTest
         Profit: $3,627      64.8% Win      PF: 1.3      ROI: 1.2      318.0 trades

         
         Optimized BackTest
         Profit: $10,244      85.7% Win      PF: 11.6      ROI: 3.409      237.0 trades
         */
    }
    
    
    func runFilteredBackTest() {
        
        var cumProfit:Double = 0.0
        var winCount:Double = 0.0
        var tradeCount:Double = 0.0
        var winningTrades:[Double] = []
        var losingTrades:[Double] = []
        var roi:[Double] = []
        
        //MARK: - Limit to 20 positions
        
        for eachTrade in allTradesSortedBtDate {
           
            let pastTrades = getHistory(forTicker: eachTrade.ticker, before: eachTrade.date!) // else {
          
            if pastTrades.avgProfit > ( 1)
                
                && eachTrade.winPct > ( 57 ) //- winPctResults.std )
                && pastTrades.avgPF > ( 0 ) // didnt help
                && pastTrades.avgROI > (0.001) //- roiResults.std )
            {
                print("\t Adding \(eachTrade.ticker) \(eachTrade.profit) because \(pastTrades.avgProfit) > \(0 )")
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
                print("\t Skip \(eachTrade.profit)")
            }
        }
        let winPct = (winCount / tradeCount) * 100
        let profitFactor = ( winningTrades.sum() / losingTrades.sum() ) * -1
        let avgRoi = roi.sum()
        
        print("\nOptimized BackTest\nProfit: $\(Utilities().dollarStr(largeNumber: cumProfit)) \t \(String(format: "%.1f", winPct))% Win \t PF: \(String(format: "%.1f", profitFactor)) \t ROI: \(String(format: "%.3f", avgRoi)) \t \(tradeCount) trades\n")
    }
    
    func getHistory(forTicker:String, before:Date) -> (avgProfit:Double, avgPF:Double, avgROI:Double) {
        
        var answer:(avgProfit:Double, avgPF:Double, avgROI:Double) = (-1.0, -1.0, -1.0)
        //print("\n test for \(Utilities().convertToStringNoTimeFrom(date: before))")
        let earlierDate = RealmUtil().sortTicker(ticker: forTicker, before: before, debug: false)
        // 1. filterbyTicker if date < This date
        // 2. average of profit
        // 3. average of pf > pf filter
        // 4. average of roi > roi filter
        let profitA: [Double] = earlierDate.map { (profit: WklyStats) in
            return profit.profit
        }
        
        let pfA: [Double] = earlierDate.map { (profitFactor: WklyStats) in
            return profitFactor.profitFactor
        }
        
        let roiA: [Double] = earlierDate.map { (roi: WklyStats) in
            return roi.roi
        }
        
        answer.avgProfit = profitA.avg()
        answer.avgPF = pfA.avg()
        answer.avgROI = roiA.avg()
        print("Average Profit = \(answer.avgProfit) average pf = \(answer.avgPF) average roi = \(answer.avgROI)")
        
        return answer
    }
    
    func graphicStats(result:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double), type:String) {
        print("\n\(type) \t\t \(Int(result.min))  ----  \(Int(result.avg - result.std)) <<< \(Int(result.avg)) [\(Int(result.mode))] >>> \(Int(result.avg + result.std)) ---- \(Int(result.max))\n")
    }
    
    func graphicStatsFloat(result:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double), type:String) {
        
        print("\n\(type) \t\t \(String(format: "%.2f", (result.min * 100)))  ----  \(String(format: "%.3f", (result.avg - result.std) * 100)) <<< \(String(format: "%.3f", (result.avg * 100))) [\(String(format: "%.3f", (result.mode * 100)))] >>> \(String(format: "%.3f", (result.avg + result.std) * 100)) ---- \(String(format: "%.3f", (result.max * 100)))\n")
    }
    
    func calcProfit(allTrades: Results<WklyStats> ) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {

        let profit: [Double] = allTrades.map { (profit: WklyStats) in
            return profit.profit
        }

        return doMath(arrayToCheck: profit)
    }
    
    func calcWinPct(allTrades: Results<WklyStats> ) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        
        let winPctA: [Double] = allTrades.map { (winPct: WklyStats) in
            return winPct.winPct
        }

        return doMath(arrayToCheck: winPctA)
    }
    
    func calcPF(allTrades: Results<WklyStats> ) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        
        let pfA: [Double] = allTrades.map { (profitFactor: WklyStats) in
            return profitFactor.profitFactor
        }
        return doMath(arrayToCheck: pfA)
    }
    
    func calcROI(allTrades: Results<WklyStats> ) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        
        let roi: [Double] = allTrades.map { (roi: WklyStats) in
            return roi.roi
        }
        return doMath(arrayToCheck: roi)
    }
    
    func doMath(arrayToCheck: [Double] ) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        
        var answer:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        if let maxInArr = arrayToCheck.max(), let minProfit = arrayToCheck.min() {
            
            let sumOfArr = arrayToCheck.reduce(0, +)
            let avgOfArr = arrayToCheck.avg()
            
            let modeOfArr = arrayToCheck.reduce([Double: Int]()) {
                var counts = $0
                counts[$1] = ($0[$1] ?? 0) + 1
                return counts
                }.max { $0.1 < $1.1 }?.0
            
            let stdDev = arrayToCheck.std()
            
            
            answer.max = maxInArr
            answer.min = minProfit
            answer.sum = sumOfArr
            answer.avg = avgOfArr
            answer.mode = modeOfArr!
            answer.std = stdDev
        }
        return answer
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

// how do I get a floatting star rating?
// star rating or Go / no go?
// with profit, win%, PF
//      1. find the aperage profit of all trades
//      2. if profit grater than average thumbs up
