//
//  Winners.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/15/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class Winners: Object {
    @objc dynamic var ticker     = ""
    @objc dynamic var date:Date?
    @objc dynamic var taskID     = ""
    
    func deleteOld() {
        let realm = try! Realm()
        let lastFile = realm.objects(Winners.self)
        try! realm.write {
            realm.delete(lastFile)
        }
        print("Winners Object Deleted")
    }
    
    func createNew(ticker:String, date:Date) {
        let realm = try! Realm()
        let winners = Winners()
        winners.taskID = NSUUID().uuidString
        winners.ticker = ticker
        winners.date = date
        
        try! realm.write({
            realm.add(winners)
        })
    }
    
    func sortTickers(months:Int, debug:Bool) -> Results<Winners> {
        let realm = try! Realm()
        let lastDate = Utilities().dateFrom(MonthsAgo: months)
        let sortedByDate = realm.objects(Winners.self).sorted(byKeyPath: "date", ascending: true).filter("date  >= %@", lastDate)
        print("\nWe found \(sortedByDate.count) tickers in the last \(months) months\n")
        if ( debug ) {
            for each in sortedByDate {
                print("\(each.date!) \t\(each.ticker)")
            }
        }
        return sortedByDate
    }
    
    func tickerCSV() {
        let results = sortTickers(months: 10, debug: false)
        var winners = ""
        for each in results {
            winners += "\(each.ticker), "
        }
        print(winners)
    }
    
}
