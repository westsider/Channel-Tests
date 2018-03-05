//
//  Intrinio.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/4/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Intrinio {
    
    var downloadErrors: Array<String> = []
    let realm = try! Realm()
    
    func standatdNetworkCall(ticker: String, debug: Bool, completion: @escaping (Bool) -> Void) {
        
        let lastFile = realm.objects(Prices.self)
        try! realm.write {
            realm.delete(lastFile)
        }
        
        for page in 1...3 {
            
            print("Requesting remote data for \(ticker) page \(page)")
            //let request = "https://api.intrinio.com/prices?ticker=\(ticker)" //DWDP
            let user = Utilities().getUser().user
            let password = Utilities().getUser().password
            let loginData = String(format: "%@:%@", user, password).data(using: String.Encoding.utf8)!
            let base64LoginData = loginData.base64EncodedString()
            var lastHigh:Double = 0.0
            var lastLow:Double = 0.0
            
            // create the request
            let url = URL(string: "https://api.intrinio.com/prices?ticker=\(ticker)&page_number=\(page)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
            
            //making the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("\(error.debugDescription)")
                    return
                }
                let json = JSON(data)
                if ( debug ) { print("JSON: \(json)") }
                if let httpStatus = response as? HTTPURLResponse {
                    // check status code returned by the http server and process result
                    Process.httpStatus(service: "alpha vantage", httpStatus: httpStatus.statusCode, ticker: ticker)
                    if httpStatus.statusCode != 200 {
                        self.downloadErrors.append("Error getting \(ticker): Code \(httpStatus.statusCode)")
                    }
                }
                
                for data in json["data"].arrayValue {
                    if ( debug ) { print("\n---------------> starting json loop  <---------------------") }
                    let prices = Prices()
                    prices.ticker = ticker
                    if let date = data["date"].string {
                        if ( debug ) {  print("\nHere is the date to test \(date)") }
                        prices.dateString = date
                        prices.date = Utilities().convertToDateFrom(string: date, debug: false)
                    }
                    if let close = data["close"].double { prices.close = close }
                    if let volume = data["volume"].double { prices.volume = volume }
                    if let open = data["open"].double { prices.open = open }
                    if let high = data["high"].double { prices.high = high } else {
                        prices.high = lastHigh
                    }
                    if let low = data["low"].double { prices.low = low } else {
                        prices.low = lastLow
                    }
                    
                    lastLow = prices.high
                    lastHigh = prices.low
                    
                    try! self.realm.write({
                        self.realm.add(prices)
                    })
                }
                
                if ( debug ) { print("\(ticker) request complete for page \(page)") }
                if page == 3 {
                    completion(true)
                }
            }
            task.resume()
        }
    }
}
