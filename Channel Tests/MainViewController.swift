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

// [ ] make array for chart
// [ ] make chart
// [ ] add pre / post optimization to chart
// [ ] add cost to chart
// [ ] display % capital used
// [ ] add stats to chart
// [ ] print tickers that pass optimization

import UIKit

class MainViewController: UIViewController, ClassBVCDelegate {

    @IBOutlet weak var updateText: UILabel!
    
    var firebaseLink = FirebaseLink()
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
            
//        firebaseLink.authAndGetFirebase { (finished) in
//            if finished {
//                //WklyStats().getWeeklyStatsFromRealm()
//                //let _ = RealmUtil().sortOneTicker(ticker: "CSCO", debug: true)
//                Statistics().getDistribution()
//                self.stdBacktest = Statistics().standardBackTest(debug: false)
//                self.optBacktest = Statistics().optimizedBackTest(debug: false)
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
        stdBacktest = Statistics().standardBackTest(debug: false)
        optBacktest = Statistics().optimizedBackTest(debug: false)
        print("std count \(stdBacktest.count) opt coint \(optBacktest.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if optBacktest.count == stdBacktest.count {
            changeUImessage(message: "Both arrays match in size. trasition to charts ok/")
        }
    }
    
    @IBAction func statsButtonAction(_ sender: UIButton) {
        segueToStats()
    }
    
    
    func changeUImessage(message: String) {
        print("MESSAGE FROM DELAGATE: \(message)");
        DispatchQueue.main.async {
            self.updateText.text = message
        }
    }
    
    private func segueToStats() {
        let myVC:StatsViewController = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        myVC.stdBacktest = stdBacktest
        myVC.optBacktest = optBacktest
        navigationController?.pushViewController(myVC, animated: true)
    }
}

