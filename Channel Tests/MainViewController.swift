//
//  ViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

// [X] make apikeys ui
// [X] get spy only gets 100 after marker closed
// [X] realm accessed from wrong thread in backtest opt
// [X] send tickers that pass ticker to mail as comma separated txt
// [X] share button disabled till backtest has run
// [X] run new optimization
// [X] share sits in outbox on ipad
// [X] upgrade server to 2 cores from $15 - $30
// [X] Stock market data and charting in swift
// [X] show improvement of market condition

// [ ] show distribution of profit relative to SPY wPctR
// [ ] get Entry date wpcrR
// [ ] Match entry date trade -> profit
// [ ] Array (wpctR, profit)
// [ ] plot Y: woctR, plot X: profit
    /*
    For each exit
    Get entrydate
    Get wpctr, profit-> Array (wpctR, profit)
     */
// [ ] largest drawdown, extra stats to main UI
// [ ] add distribution stats -> realm -> main UI

import Foundation
import UIKit
import MessageUI

class MainViewController: UIViewController, FirebaseDelegate, AlphaDelegate, SMADelegate, WpctrDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mainText: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var sharBttn: UIButton!
    
    var firebaseLink = FirebaseLink()
    var alphaLink = Alpha()
    var smaLink = SMA()
    var wpctrLink = WpctR()
    
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var textForUI = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        alphaLink.delegate = self
        smaLink.delegate = self
        wpctrLink.delegate = self
        
        checkPasswords()
        title = "Channel"
        DispatchQueue.main.async {
            self.textForUI += "\n\(MarketHours().currentTimeText())\t\(MarketHours().isMarketOpen())\t"
            self.textForUI += SpReturns().showProfitInUI()
        }
//        activitIsNow(on: true)
//        alphaLink.checkForNewPrices { (finished) in
//            if finished {
//                DispatchQueue.main.async {
//                    self.mainText.text = self.textForUI
//                    self.smaLink.standardNetworkCall(ticker: "SPY", compact: false, debug: false) { (finished) in
//                        if finished {
//                            MarketCondition().addMCtoRealm()
//                            self.wpctrLink.standardNetworkCall(ticker: "SPY", compact: false, debug: false, completion: { (finished) in
//                                if finished {
//                                    self.activitIsNow(on: false)
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        }
    }
    
    @IBAction func getNewDataAction(_ sender: Any) {
        newBacktest()
    }
    
    @IBAction func statsButtonAction(_ sender: UIButton) {
        segueToStats()
    }
    
    @IBAction func sendTickers(_ sender: Any) {
        sendEmail()
    }
    
    @IBAction func wpctrAction(_ sender: Any) {
        segueToWpctR()
    }
    
    
    func sendEmail() {
        let mailComposeViewController = configureMailComposer()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }

    func configureMailComposer() -> MFMailComposeViewController {
        let message = RealmUtil().optimizedPopulation(debug: true)
        let newData = message.data(using: String.Encoding.utf8) //{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["whansen1@mac.com"])
        mailComposeVC.setSubject(Utilities().convertToStringFrom(date: Date()))
        mailComposeVC.setMessageBody("Here are the optimized symbols for \(Utilities().convertToStringNoTimeFrom(date: Date()))", isHTML: true)
        mailComposeVC.addAttachmentData(newData!, mimeType: ".txt", fileName: "OptimizedSymbols")
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
                    self.changeUImessage(message: " Firebase Complete")
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
        DispatchQueue.global(qos: .background).async {
            Statistics().getDistribution { (finished) in
                if finished {
                    print("----------------------------------------------------> Distribution Complete")
                    self.changeUImessage(message: "\nDistribution Complete")
                    Statistics().standardBackTest(debug: true) { (finished) in
                        if finished {
                            print("----------------------------------------------------> STD backtest Finished!")
                            self.changeUImessage(message: "\nStandard backtest finished")
                            Statistics().optimizedBackTest(debug: true, completion: { (finished) in
                                if finished {
                                    DispatchQueue.main.async {
                                        print("----------------------------------------------------> OPT backtest finished!")
                                        self.changeUImessage(message: "\nOptimized backtest finished")
                                        //self.getStatsFromRealm()
                                        self.activitIsNow(on: false)
                                        self.sharBttn.isEnabled = true
                                        self.sharBttn.alpha = 1.0
                                    }
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
    
    func checkPasswords() {
        guard let _ = UserDefaults.standard.object(forKey: "alphaApiKey")  else {
            let myVC:LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            navigationController?.pushViewController(myVC, animated: true)
            return
        }
    }
    
    private func segueToStats() {
        let myVC:StatsViewController = storyboard?.instantiateViewController(withIdentifier: "StatsVC") as! StatsViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
    private func segueToWpctR() {
        let myVC:WpctrViewController = storyboard?.instantiateViewController(withIdentifier: "WpctrVC") as! WpctrViewController
        navigationController?.pushViewController(myVC, animated: true)
    }
}

