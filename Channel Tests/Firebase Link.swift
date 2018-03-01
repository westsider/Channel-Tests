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

class FirebaseLink {
    
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
                print("\nSigned into Firebase as: \(self.userEmail)\n")
                self.fetchData(debug: true, dataComplete: { (finished) in
                    if finished {
                        print("finishedgetting data from firebase");
                    }
                })
            } else {
                print(error ?? "something went wrong getting error")
            }
        }
    }
    
     func fetchData(debug: Bool, dataComplete: @escaping (Bool) -> Void) {
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            print("getting snapshot");
            if snapshot.childrenCount > 0 {

                for items in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    // get all other values ticker ect
                    if let data    = items.value as? [String: AnyObject] {
                        self.parseFrom(data: data)
                    } else {
                        print("failed to unwrap data!");
                    }
                }
                print("got snapshot");
                dataComplete(true) // i put this after the network call and the real write
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
 
        print("Ticker \(ticker) \tDate: \(date) \tProfit: \(profit)");

    }
}
