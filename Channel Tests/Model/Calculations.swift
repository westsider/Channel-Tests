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
