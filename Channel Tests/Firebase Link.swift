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
    
    var fileCount:Int = 0
    
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
                        DispatchQueue.main.async {
                            self.delegate?.changeUImessage(message: "finished getting data from firebase")
                        }
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
                let allItems = snapshot.children.allObjects as! [DataSnapshot]
                //print("all items count \(allItems.count)")
                for items in snapshot.children.allObjects as! [DataSnapshot] {
                   
                    DispatchQueue.global(qos: .userInitiated).async {
                        // get all other values ticker ect
                        if let data    = items.value as? [String: AnyObject] {
                            
                            self.parseFrom(data: data, debug: false)
                        } else {
                            self.delegate?.changeUImessage(message: "failed to unwrap data!")
                        }
                    }
                     //print(allItems.count, self.fileCount )
                }
               
                if self.fileCount == allItems.count {
                    dataComplete(true)
                    DispatchQueue.main.async {
                        self.delegate?.changeUImessage(message: "completed new data from firebase")
                    }
                }
            }
        })
    }
    
    func parseFrom(data: [String: AnyObject], debug: Bool ) {
        guard let ticker:String  = data["ticker"] as? String else { print("ticker fail"); return }
        DispatchQueue.main.async {
            self.delegate?.changeUImessage(message: "new data found for \(ticker)")
        }
        guard let cost    = data["cost"] as? Double else { print("cost fail"); return }
        guard let winPct = data["winPct"] as? Double else { print("winPct fail"); return }
        guard let roi    = data["roi"] as? Double else { print("roi fail"); return }
        guard let dateStr    = data["entryDate"] as? String else { print("dateStr fail"); return }
        guard let date = Utilities().convertToDateFromNT(string: dateStr, debug: false) else { print("date has failed"); return }
        
        guard let dateStrEx    = data["exitDate"] as? String else { print("ExitdateStr fail"); return }
        guard let dateEx = Utilities().convertToDateFromNT(string: dateStrEx, debug: false) else { print("date has failed"); return }
        
        guard let profit     = data["profit"] as? Double else { print("profit fail"); return }
        
        print("\(ticker) \t\(dateStr) \tProfit: \(profit) \tCost: \(cost) \t%win: \(winPct) \tROI: \(roi)\t\(String(describing: date))\t\(String(describing: dateEx))");
        self.fileCount += 1
    }
}
