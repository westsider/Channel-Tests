//
//  ViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

// [ ] make apikeys ui
// [X] get spy only gets 100 after marker closed
// [ ] realm accessed from wrong thread in backtest opt
// [ ] send tickers that pass ticker to mail as comma separated txt
// [ ] show effect of market condition
// [ ] show distribution of profit relative to SPY wPctR
// [ ] add max positions to stats
// [ ] display % capital used
// [ ] largest drawdown, extra stats to main UI
// [ ] add distribution stats -> realm -> main UI

import UIKit

class MainViewController: UIViewController, FirebaseDelegate, AlphaDelegate {
    
    @IBOutlet weak var mainText: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var firebaseLink = FirebaseLink()
    var alphaLink = Alpha()
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var textForUI = "\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        alphaLink.delegate = self
        DispatchQueue.main.async {
            self.textForUI += "\n\(MarketHours().currentTimeText())\t\(MarketHours().isMarketOpen())\t"
            self.textForUI += SpReturns().showProfitInUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activitIsNow(on: true)
        alphaLink.checkForNewPrices { (finished) in
            if finished {
                DispatchQueue.main.async {
                    print("\nDownload Completed!\n")
                    self.activitIsNow(on: false)
                    self.mainText.text = self.textForUI
                    //self.getStatsFromRealm() // prove we have data in realm
                }
            }
        }
    }
    
    @IBAction func getNewDataAction(_ sender: Any) {
        newBacktest()
    }
    
    
    @IBAction func statsButtonAction(_ sender: UIButton) {
        segueToStats()
    }
    
    func getStatsFromRealm() {
        
        if let uiText = StatsBacktests().populateUI(group: "STD") {
            DispatchQueue.main.async {
                self.textForUI += "\n\nStandard Backtest:\n"
                self.textForUI += "\(String(format: "%.1f", uiText.winPct))% win \t\(String(format: "%.2f", uiText.profitFactor)) pf \t\(String(format: "%.1f", uiText.roi))% roi \t$\(Utilities().dollarStr(largeNumber: uiText.cumProfit)) profit \t\(uiText.totalTrades) trades \t $\(Utilities().dollarStr(largeNumber: uiText.maxCost)) required\n"
                print(self.textForUI)
            }
        }
        if let uiText2 = StatsBacktests().populateUI(group: "OPT") {
            DispatchQueue.main.async {
                self.textForUI += "\n\nOptimized Backtest:\n"
                self.textForUI += "\(String(format: "%.1f", uiText2.winPct))% win \t\(String(format: "%.2f", uiText2.profitFactor)) pf \t\(String(format: "%.1f", uiText2.roi))% roi \t$\(Utilities().dollarStr(largeNumber: uiText2.cumProfit)) profit \t\(uiText2.totalTrades) trades \t $\(Utilities().dollarStr(largeNumber: uiText2.maxCost)) required\n\n"
                print(self.textForUI)
            }
        }
        DispatchQueue.main.async {
            self.mainText.text = self.textForUI
        }
    }
    
    func newBacktest() {
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
        //activitIsNow(on: true)
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
    
    func changeUImessage(message: String) {
        print("\nMESSAGE FROM Firebase: \(message)");
        DispatchQueue.main.async {
            self.textForUI += message
            self.mainText.text = self.textForUI
        }
    }
    
    func changeUImessageAlpha(message:String) {
        print("\nMESSAGE FROM Alpha: \(message)");
        DispatchQueue.main.async {
            self.textForUI += message
            self.mainText.text = self.textForUI
        }
    }
    
    private func segueToStats() {
        let myVC:StatsViewController = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
}

