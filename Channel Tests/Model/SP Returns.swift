//
//  SP Returns.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/5/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

import Foundation

class SpReturns {
    
    func textForStats(yearEnding:Int)->String {
        var answer = "nil"
        if yearEnding == 2007 {
            answer = calcTenYearsReturn(start: 98.31, end: 137.37, yearEnding: yearEnding)
            print("1997 - 2007 ", answer)
            
        } else {
            answer = calcTenYearsReturn(start: 137.37, end: 267.51, yearEnding: yearEnding)
            print("2007 - 2017 ", answer)
        }
        return answer
    }
    
    func calcTenYearsReturn(start:Double, end: Double, yearEnding:Int)->String {
        let tenYrReturn = end - start
        let annualReturn = tenYrReturn / 10
        let roi = (annualReturn / end) * 100.00
        return ("10 year benchmark ending \(yearEnding) \(String(format: "%.2f", roi))% ")
    }
    
    func calcTenYearsReturnD(start:Double, end: Double, yearEnding:Int)->Double {
        let tenYrReturn = end - start
        let annualReturn = tenYrReturn / 10
        let roi = (annualReturn / end) * 100.00
        return roi
    }
    
    func calcDatesOnChart(start:Double, end: Double)->Double {
        let totalReturn = end - start
        let annualReturn = totalReturn / 5
        let roi = (annualReturn / end) * 100.00
        return roi
    }
    
    func calcDatesOnChartProfit(start:Double, end: Double)->Double {
        let shares = 33000 / start
        let profit = (end - start) * shares
        return profit
    }
    
    func showProfitInUI() -> String {
        var message = ""
        let fiveyrSP = SpReturns().calcDatesOnChart(start: 163.54, end: 271.65)
        message = "\nS&P returned \(String(format: "%.2f", fiveyrSP))% annually for the same years on the chart, "
        let profit = SpReturns().calcDatesOnChartProfit(start: 163.54, end: 271.65)
        message += "for a total profit of $\(Utilities().dollarStr(largeNumber: profit))"
        
        let roi = (201 * 163.54 ) / (201 * 271.65 ) * 100
        message += " \(String(format: "%.2f", roi))% roi\n"
        return message
    }
    
}
