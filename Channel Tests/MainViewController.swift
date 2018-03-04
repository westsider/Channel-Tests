//
//  ViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//
    /*
     Standard BackTest
     ---------------------------------------------------------------------------------------------
     57.6% Win     PF: 1.28     ROI: 6.18%    Profit $20,315     2,857 Trades     $72,728 Cost
     ---------------------------------------------------------------------------------------------
     Optimized BackTest
     ---------------------------------------------------------------------------------------------
     69.5% Win     PF: 1.86     ROI: 106.90%    Profit $38,821     2,211 Trades     $36,316 Cost
     ---------------------------------------------------------------------------------------------
     */

import UIKit

class MainViewController: UIViewController, ClassBVCDelegate {

    @IBOutlet weak var updateText: UILabel!
    
    var firebaseLink = FirebaseLink()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
//        firebaseLink.authAndGetFirebase { (finished) in
//            if finished {
//                //WklyStats().getWeeklyStatsFromRealm()
//                //let _ = RealmUtil().sortOneTicker(ticker: "CSCO", debug: true)
//                Statistics().getDistribution()
//                Statistics().standardBackTest(debug: false)
//                Statistics().optimizedBackTest(debug: true)
////                RealmUtil().setCumProfitForAllTickers(dataComplete: { (finished) in
////                    if finished {
////                        print("finished setting cum profit")
////                        StarRating().setStars(minWinPct: 65.0, minROI: 0.001, minPF: 1.00, minCumProfit: 20)
////                    }
////                })
//            }
//        }
        firebaseLink.authOnly()
        Statistics().getDistribution()
        Statistics().standardBackTest(debug: false)
        Statistics().optimizedBackTest(debug: false)
    }
    
    func changeUImessage(message: String) {
        print("MESSAGE FROM DELAGATE: \(message)");
        DispatchQueue.main.async {
            self.updateText.text = message
        }
    }
}

