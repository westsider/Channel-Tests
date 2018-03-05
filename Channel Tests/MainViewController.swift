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


// [X] add pre optimization to chart
// [ ] get stats from realm
// [ ] button to fetch firebase
// [ ] put spy in the top chart
// [ ] add stats to main vc
// [ ] display % capital used
// [ ] print tickers that pass ticker to mail
// [ ] completion handler for data fetch and processing
// [ ] use operation to thread http://iosbrain.com/blog/2018/03/04/concurrency-in-ios-introduction-to-the-abstract-operation-class-and-using-its-blockoperation-subclass-to-run-tasks-in-parallel/


import UIKit

class MainViewController: UIViewController, FirebaseDelegate, AlphaDelegate {

    @IBOutlet weak var mainText: UITextView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var firebaseLink = FirebaseLink()
    var alphaLink = Alpha()
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        alphaLink.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        alphaLink.checkRealmDatabase() //Prices().deleteOld()
        //getFirebaseData() // this should be a button with a completion handler "Get New Data From Firebase"
        mainText.text = "here is some text"
        getStatsFromRealm()
    }
    
    func getStatsFromRealm() {
        
        if let uiText = StatsBacktests().populateUI(group: "STD") {
            print("\nStandard Backtest:")
            print("Win \(uiText.winPct) \tpf \(uiText.profitFactor) \troi \(uiText.roi) \tProfit\(uiText.cumProfit) \ttrades \(uiText.totalTrades) \t cost\(uiText.maxCost)" )
        }
        if let uiText2 = StatsBacktests().populateUI(group: "OPT") {
            print("\nOptimized Backtest:")
            print("Win \(uiText2.winPct) \tpf \(uiText2.profitFactor) \troi \(uiText2.roi) \tProfit\(uiText2.cumProfit) \ttrades \(uiText2.totalTrades) \t cost\(uiText2.maxCost)\n" )
        }
    }
    
    func getFirebaseData() {
        // add activity
        activitIsNow(on: true)
        DispatchQueue.global(qos: .background).async {
            self.firebaseLink.authAndGetFirebase { (finished) in
                if finished {
                    self.backtestWithFilters()
                }
            }
        }
    }
    
    func activitIsNow(on:Bool) {
        DispatchQueue.main.async {
            if on {
                self.activity.startAnimating()
            } else {
                self.activity.stopAnimating()
            }
        }
    }
    
    func backtestWithFilters() {
        // add activity
        activitIsNow(on: true)
        activity.color = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        DispatchQueue.global(qos: .background).async {
            Statistics().getDistribution { (finished) in
                if finished {
                    print("----------------------------------------------------> Distribution Complete")
                    self.changeUImessage(message: "Distribution Complete")
                    Statistics().standardBackTest(debug: true) { (finished) in
                        if finished {
                            print("----------------------------------------------------> STD backtest Finished!")
                            self.changeUImessage(message: "STD backtest Finished")
                            Statistics().optimizedBackTest(debug: true, completion: { (finished) in
                                if finished {
                                    print("----------------------------------------------------> OPT backtest finished!")
                                    self.changeUImessage(message: "OPT backtest finished")
                                    self.getStatsFromRealm()
                                    self.activitIsNow(on: false)
                                }
                            })
                        }
                    }
                }
            }
        }
        print("std count \(stdBacktest.count) opt coint \(optBacktest.count)")
    }
    

    @IBAction func getNewDataAction(_ sender: Any) {
        getFirebaseData()
    }
    
    
    @IBAction func statsButtonAction(_ sender: UIButton) {
        segueToStats()
    }
    
    func changeUImessage(message: String) {
        print("\nMESSAGE FROM Firebase: \(message)");
        DispatchQueue.main.async {
            self.mainText.text = message
        }
    }
    
    func changeUImessageAlpha(message:String) {
        print("\nMESSAGE FROM Alpha: \(message)");
        DispatchQueue.main.async {
            self.mainText.text = message
        }
    }
    
    private func segueToStats() {
        let myVC:StatsViewController = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        myVC.stdBacktest = stdBacktest
        myVC.optBacktest = optBacktest
        navigationController?.pushViewController(myVC, animated: true)
    }
}

