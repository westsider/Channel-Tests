//
//  ViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//
//  [X] Login firebase pods: firebase, realm
//  [X] request json
//  [X] parse json
//  [X] use protocol to update UI
//  [X] convert string to date
//  [X] save to realm as WeeklyStats (stringDate, date, profit, cumProfit, winPct, cost, ROI , annualRoi?, ticker, stars)
//  [ ] market condition

import UIKit

class MainViewController: UIViewController, ClassBVCDelegate {

    @IBOutlet weak var updateText: UILabel!
    
    var firebaseLink = FirebaseLink()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        firebaseLink.authAndGetFirebase { (finished) in
            if finished {
                //WklyStats().getWeeklyStatsFromRealm()
                let _ = RealmUtil().sortOneTicker(ticker: "CSCO", debug: true)
                Statistics().getDistribution()
                
//                RealmUtil().setCumProfitForAllTickers(dataComplete: { (finished) in
//                    if finished {
//                        print("finished setting cum profit")
//                        StarRating().setStars(minWinPct: 65.0, minROI: 0.001, minPF: 1.00, minCumProfit: 20)
//                    }
//                })
            }
        }
    }
    
    func changeUImessage(message: String) {
        print("MESSAGE FROM DELAGATE: \(message)");
        DispatchQueue.main.async {
            self.updateText.text = message
        }
    }
}

