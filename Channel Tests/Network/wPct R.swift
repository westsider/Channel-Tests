//
//  wPct R.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/20/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WpctrDelegate: class {
    func changeUImessageAlpha(message:String)
}

class WpctR {
    
    var downloadErrors: Array<String> = []
    
    weak var delegate: WpctrDelegate?
    
    // completion hamdler / activity indicator
    func checkForNewPrices( completion: @escaping (Bool) -> Void) {
        //if time < 1300 return
        let answer = MarketHours().isMarketOpen()
        if answer != "Market Closed" {
            delegate?.changeUImessageAlpha(message: "\nMarket is open, waiting to update SPY till close")
            completion(true)
            return }
        // otherwise always get new market data for SPY
        DispatchQueue.global(qos: .background).async {
            self.standardNetworkCall(ticker: "SPY", compact: false, debug: true) { (finished) in
                if finished {
                    completion(true)
                    let spyPrices = Prices().sortOneTicker(ticker: "SPY", debug: false)
                    self.delegate?.changeUImessageAlpha(message: "\nSpy database has been updated and has \(Utilities().dollarStr(largeNumber: Double(spyPrices.count))) days")
                }
            }
        }
    }
    
    func standardNetworkCall(ticker: String, compact:Bool, debug: Bool, completion: @escaping (Bool) -> Void) {
        
        delegate?.changeUImessageAlpha(message: "\nContacting NYSE for wPct(R) on \(ticker)")
        guard let alphaApiKey = UserDefaults.standard.object(forKey: "alphaApiKey")  else {
            Alert.showBasic(title: "Warning", message: "No Api Key for Alpha.")
            return
        }
        
        // https://www.alphavantage.co/query?function=WILLR&symbol=MSFT&interval=15min&time_period=10&apikey=demo
        
        guard let url = URL(string: "https://www.alphavantage.co/query?function=WILLR&symbol=\(ticker)&interval=daily&time_period=10&series_type=close&apikey=\(alphaApiKey)") else {
            print("Alpha URL did not un wrap!")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("\(error.debugDescription)")
                return
            }
            let json = JSON(data)
            if ( debug ) { print(json) }
            if let httpStatus = response as? HTTPURLResponse {
            
                let message = Process.httpStatus(service: "alph avantage", httpStatus: httpStatus.statusCode, ticker: ticker)
                if httpStatus.statusCode != 200 {
                    self.downloadErrors.append("Error getting \(ticker): Code \(httpStatus.statusCode)")
                }
                self.delegate?.changeUImessageAlpha(message: message)
            }
            let alldata = json["Technical Analysis: WILLR"] as JSON
            for (dateSeries,timeSeries):(String, JSON) in alldata {
                let wPctR = timeSeries["WILLR"]
                
                if ( debug ) { print("\(dateSeries) \(wPctR.doubleValue)") }
                Prices().addWpctR(ticker: ticker, date: dateSeries, wpctr: wPctR.doubleValue, debug: debug)
            }
            self.delegate?.changeUImessageAlpha(message: "\nReceived all wPct(R) data for \(ticker)")
            completion(true)
        }
        task.resume()
    }
}
