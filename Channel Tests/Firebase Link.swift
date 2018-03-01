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
protocol ClassBVCDelegate: class {
    func changeUImessage(message:String)
}


class FirebaseLink {
    
    //MARK: step 2 Create a delegate property here, don't forget to make it weak!
    weak var delegate: ClassBVCDelegate?
    
    var ref: DatabaseReference!
    
    var userEmail = ""
    
    var currentLongEntryPrice:Double = 0.0
    
    var currentShortEntryPrice:Double = 0.0
    
    func authAndGetFirebase() {
        
        ref = Database.database().reference()//.child(currentChild) //.child("Table1")
        let email = "whansen1@mac.com"
        let password = "123456"
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil {
                self.userEmail = (user?.email!)!
                self.delegate?.changeUImessage(message: "Signed into Firebase as: \(self.userEmail)l")
                self.fetchData(debug: true, dataComplete: { (finished) in
                    if finished {
                        self.delegate?.changeUImessage(message: "finished getting data from firebase")
                    }
                })
            } else {
                self.delegate?.changeUImessage(message: error.debugDescription )
            }
        }
    }
    
     func fetchData(debug: Bool, dataComplete: @escaping (Bool) -> Void) {
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.delegate?.changeUImessage(message: "requesting data from firebase")
                for items in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    // get all other values ticker ect
                    if let data    = items.value as? [String: AnyObject] {
                        self.parseFrom(data: data)
                    } else {
                        self.delegate?.changeUImessage(message: "failed to unwrap data!")
                    }
                }
                dataComplete(true)
            }
        })
    }
    
    func parseFrom(data: [String: AnyObject] ) {
        guard let ticker:String  = data["ticker"] as? String else { print("ticker fail"); return }
        guard let cost    = data["cost"] as? Double else { print("cost fail"); return }
        guard let winPct = data["winPct"] as? Double else { print("winPct fail"); return }
        guard let roi    = data["roi"] as? Double else { print("roi fail"); return }
        guard let date    = data["date"] as? String else { print("date fail"); return }
        guard let profit     = data["profit"] as? Double else { print("profit fail"); return }
 
        print("Ticker \(ticker) \tDate: \(date) \tProfit: \(profit) \tCost: \(cost) \t%win: \(winPct) \tROI: \(roi)");

    }
}
