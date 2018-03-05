//
//  Alpha.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/4/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol AlphaDelegate: class {
    func changeUImessageAlpha(message:String)
}

class Alpha {
    
    var downloadErrors: Array<String> = []
    
    weak var delegate: AlphaDelegate?

    func checkRealmDatabase() {
        let lastUpdateWasToday = Utilities().lastUpdateWasToday(ticker: "SPY", debug: true)
        if !lastUpdateWasToday {
            delegate?.changeUImessageAlpha(message: "spy database isn't current")
            getData(forTicker: "SPY", compact: true, debug: true)
        } else {
            let spyPrices = Prices().sortOneTicker(ticker: "SPY", debug: false)
            delegate?.changeUImessageAlpha(message: "spy database is current with \(spyPrices.count) records")
        }
    }
    
    func getData(forTicker:String, compact:Bool, debug:Bool) {
        standardNetworkCall(ticker: forTicker, compact: compact, debug: debug) { (finished) in
            if finished {
                let spyPrices = Prices().sortOneTicker(ticker: forTicker, debug: debug)
                print("Spy database has \(spyPrices.count) records")
                self.delegate?.changeUImessageAlpha(message: "\(forTicker) Dates count \(spyPrices.count) in databse")
            }
        }
    }
    
    func standardNetworkCall(ticker: String, compact:Bool, debug: Bool, completion: @escaping (Bool) -> Void) {
        
        
        Prices().deleteOld()
        print("Requesting remote data for \(ticker)")
        delegate?.changeUImessageAlpha(message: "Requesting alpha data for \(ticker)")
        let alphaApiKey = UserDefaults.standard.object(forKey: "alphaApiKey") as! String
        var additionalData = ""

        if !compact {  additionalData = "&outputsize=full"}
        guard let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(ticker)\(additionalData)&apikey=\(alphaApiKey)") else {
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
            //MARK: TODO - unwrap all
            let metadata = json["Meta Data"] as JSON
            let lastRefreshed = metadata["3. Last Refreshed"]
            let symbol = metadata["2. Symbol"]
            let zone = metadata[ "5. Time Zone"]
            let info = metadata["1. Information"]
            let size = metadata["4. Output Size"]
            if ( debug ) { print("\nMetadata")
                print("Last Refreshed \(lastRefreshed) symbol \(symbol) zone \(zone) info \(info) size \(size)") }
            
            let alldata = json["Time Series (Daily)"] as JSON
            for (dateSeries,timeSeries):(String, JSON) in alldata {
                let open = timeSeries["1. open"]
                let high = timeSeries["2. high"]
                let low = timeSeries["3. low"]
                let close = timeSeries["4. close"]
                let volume = timeSeries["5. volume"]
                
                if ( debug ) { print("\(dateSeries) \(symbol) o:\(open) h:\(high) low:\(low) c:\(close) v\(volume)") }
                Prices().createNew(ticker: symbol.stringValue, lastRefreshed: lastRefreshed.stringValue, dateString: dateSeries, open: open.doubleValue, high: high.doubleValue, low: low.doubleValue, close: close.doubleValue, vol: volume.doubleValue)
                
            }
            print("Requesting alpha data for \(ticker)")
            self.delegate?.changeUImessageAlpha(message: "Requesting alpha data for \(ticker)")
            completion(true)
        }
        task.resume()
    }
}

