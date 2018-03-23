//
//  Calculations.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/2/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import  RealmSwift
class Calculations {
    
    func graphicStats(result:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double), type:String) {
        print("\n\t\(type) \t\t \(Int(result.min))  ----  \(Int(result.avg - result.std)) <<< \(Int(result.avg)) [\(Int(result.mode))] >>> \(Int(result.avg + result.std)) ---- \(Int(result.max))\n")
    }
    
    func graphicStatsFloat(result:(max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double), type:String) {
        
        print("\n\t\(type) \t\t \(String(format: "%.2f", (result.min * 100)))  ----  \(String(format: "%.3f", (result.avg - result.std) * 100)) <<< \(String(format: "%.3f", (result.avg * 100))) [\(String(format: "%.3f", (result.mode * 100)))] >>> \(String(format: "%.3f", (result.avg + result.std) * 100)) ---- \(String(format: "%.3f", (result.max * 100)))\n")
    }
    
    func calcProfit() -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
        let profit: [Double] = allTradesSortedBtDate.map { (profit: WklyStats) in
            return profit.profit
        }
        
        return doMath(arrayToCheck: profit)
    }
    
    func calcProfit(ticker: String) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {

        if let thisTicker = WklyStats().getOneTicker(ticker: ticker) {
            let profit: [Double] = thisTicker.map { (profit: WklyStats) in
                return profit.profit
            }
            return doMath(arrayToCheck: profit)
        } else {
            return (max:0.0, min:0.0, sum:0.0, avg:0.0, mode:0.0, std:0.0)
        }
    }
    
    func calcWinPct() -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
        let winPctA: [Double] = allTradesSortedBtDate.map { (winPct: WklyStats) in
            return winPct.winPct
        }
        
        return doMath(arrayToCheck: winPctA)
    }
    
    func calcWinPct(ticker: String) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        if let thisTicker = WklyStats().getOneTicker(ticker: ticker) {
            let winPctA: [Double] = thisTicker.map { (winPct: WklyStats) in
                return winPct.winPct
            }
            return doMath(arrayToCheck: winPctA)
        } else {
            return (max:0.0, min:0.0, sum:0.0, avg:0.0, mode:0.0, std:0.0)
        }

    }
    
    func calcPF() -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
        let pfA: [Double] = allTradesSortedBtDate.map { (profitFactor: WklyStats) in
            return profitFactor.profitFactor
        }
        return doMath(arrayToCheck: pfA)
    }
    
    func calcPF(ticker: String) -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        if let thisTicker = WklyStats().getOneTicker(ticker: ticker) {
            let pfA: [Double] = thisTicker.map { (profitFactor: WklyStats) in
                return profitFactor.profitFactor
            }
            return doMath(arrayToCheck: pfA)
        } else {
            return (max:0.0, min:0.0, sum:0.0, avg:0.0, mode:0.0, std:0.0)
        }
    }
    
    func calcROI() -> (max:Double, min:Double, sum:Double, avg:Double, mode:Double, std:Double) {
        let allTradesSortedBtDate =  RealmUtil().getAllWklyStats(debug: false)
        let roi: [Double] = allTradesSortedBtDate.map { (roi: WklyStats) in
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
