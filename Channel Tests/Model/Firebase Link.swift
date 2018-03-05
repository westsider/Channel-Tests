//
//  Firebase Link.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//MARK: step 1 Add Protocol here
protocol FirebaseDelegate: class {
    func changeUImessage(message:String)
}

class FirebaseLink {
    
    //MARK: step 2 Create a delegate property here, don't forget to make it weak!
    weak var delegate: FirebaseDelegate?
    
    var ref: DatabaseReference!
    
    var userEmail = ""
    
    var currentLongEntryPrice:Double = 0.0
    
    var currentShortEntryPrice:Double = 0.0
    
    var fileCount:Int = 0
    
    func authOnly() {
        ref = Database.database().reference()//.child(currentChild) //.child("Table1")
        let email = "whansen1@mac.com"
        let password = "123456"
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                self.userEmail = (user?.email!)!
                print("Signed into Firebase as: \(self.userEmail)l")
            } else {
                self.delegate?.changeUImessage(message: error.debugDescription )
            }
        }
    }
    
    func authAndGetFirebase( dataComplete: @escaping (Bool) -> Void) {
        
        ref = Database.database().reference()//.child(currentChild) //.child("Table1")
        let email = "whansen1@mac.com"
        let password = "123456"
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                if error == nil {
                    self.userEmail = (user?.email!)!
                    self.delegate?.changeUImessage(message: "Signed into Firebase as: \(self.userEmail)l")
                    self.fetchData(debug: true, dataComplete: { (finished) in
                        if finished {
                            self.delegate?.changeUImessage(message: "finished getting data from firebase")
                            dataComplete(true)
                        }
                    })
                } else {
                    self.delegate?.changeUImessage(message: error.debugDescription )
                }
            }
        }
    }
    
    func fetchData(debug: Bool, dataComplete: @escaping (Bool) -> Void) {
        
        WklyStats().clearWeekly()
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.delegate?.changeUImessage(message: "requesting data from firebase")
                let allItems = snapshot.children.allObjects as! [DataSnapshot]
                for items in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    // get all other values ticker ect
                    if let data    = items.value as? [String: AnyObject] {
                        
                        self.parseFrom(data: data, debug: false)
                    } else {
                        self.delegate?.changeUImessage(message: "failed to unwrap data!")
                    }
                    
                    //if debug { print(allItems.count, self.fileCount ) }
                }
                if self.fileCount == allItems.count {
                    dataComplete(true)
                    self.delegate?.changeUImessage(message: "new data from firebase")
                }
            }
        })
    }
    
    func parseFrom(data: [String: AnyObject], debug: Bool ) {
        guard let ticker:String  = data["ticker"] as? String else { print("ticker fail"); return }
        
        self.delegate?.changeUImessage(message: "new data for \(ticker)")
        guard let cost    = data["cost"] as? Double else { print("cost fail"); return }
        guard var winPct = data["winPct"] as? Double else { print("winPct fail"); return }
        guard let roi    = data["roi"] as? Double else { print("roi fail"); return }
        guard let dateStr    = data["entryDate"] as? String else { print("dateStr fail"); return }
        guard let date = Utilities().convertToDateFromNT(string: dateStr, debug: false) else { print("date has failed"); return }
        guard let dateStrEx    = data["exitDate"] as? String else { print("ExitdateStr fail"); return }
        guard let dateEx = Utilities().convertToDateFromNT(string: dateStrEx, debug: false) else { print("date has failed"); return }
        guard let profit     = data["profit"] as? Double else { print("profit fail"); return }
        guard var profitFactor = data["profitFactor"] as? Double else { print("profitFactor has failed"); return }
        
        // normalise the early trades
        if profitFactor > 50 {
            profitFactor = 1
        }
        
        if winPct == 100 {
            winPct = 60.0
        }
        if debug {
            print("\(ticker) \t\(dateStr) \tProfit: \(profit) \tCost: \(cost) \t%win: \(winPct) \tROI: \(roi)\t\(String(describing: date))\t\(String(describing: dateEx))"); }
        self.fileCount += 1
        
        //save to realm as WeeklyStats (stringDate, date, profit, cumProfit, winPct, cost, ROI , annualRoi?, ticker, stars)
        WklyStats().updateCumulativeProfit(date: dateEx, entryDate: date, ticker: ticker, profit: profit, winPct: winPct, roi: roi, profitFactor: profitFactor, cost: cost, maxCost: 0.0)
    }
}
