//
//  WptcR Results.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/21/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import RealmSwift

class WpctrStats: Object {
    @objc dynamic var profit   = 0.00
    @objc dynamic var wpctR    = 0.00
    
    func deleteOld() {
        let realm = try! Realm()
        let weekly = realm.objects(WpctrStats.self)
        try! realm.write {
            realm.delete(weekly)
        }
        print("\nRealm \tWpctrStats \tCleared!\n")
    }
    
    func addToRealm(profit: Double, wpctR: Double) {
        let realm = try! Realm()
        let thisTest = WpctrStats()
        thisTest.profit = profit
        thisTest.wpctR = wpctR
        try! realm.write {
            realm.add(thisTest)
        }
    }
    
    func getAllStats(debug:Bool)-> Results<WpctrStats> {
        let realm = try! Realm()
        let allWpctrStats = realm.objects(WpctrStats.self)
        if debug {
            print("\nwpct(R) ----->")
            for each in allWpctrStats {
                print("$\(each.profit) \t\(each.wpctR) %R")
            }
        }
        return allWpctrStats
    }
}
