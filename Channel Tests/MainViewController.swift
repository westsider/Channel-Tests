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
// [ ] only 42 symbols added
// [ ] show effect of market condition
// [ ] show distribution of profit relative to SPY wPctR

// [ ] largest drawdown, extra stats to main UI
// [ ] add distribution stats -> realm -> main UI
import Foundation
import UIKit
import MessageUI

class MainViewController: UIViewController, FirebaseDelegate, AlphaDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mainText: UITextView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var sharBttn: UIButton!
    
    var firebaseLink = FirebaseLink()
    var alphaLink = Alpha()
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var textForUI = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        alphaLink.delegate = self
        checkPasswords()
        title = "Channel"
        DispatchQueue.main.async {
            self.textForUI += "\n\(MarketHours().currentTimeText())\t\(MarketHours().isMarketOpen())\t"
            self.textForUI += SpReturns().showProfitInUI()
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            let winners = RealmUtil().optimizedPopulation(debug: true)
            mail.mailComposeDelegate = self
            mail.setToRecipients(["whansen1@mac.com"])
            mail.setSubject("Tickers optimized on \(Utilities().convertToStringNoTimeFrom(date: Date()))")
            mail.setMessageBody(winners, isHTML: false)

            present(mail, animated: true)
        } else {
            print("\n---------------------------\n\tMail has failed\n---------------------------\n")
            Alert.showBasic(title: "Mail Problem", message: "Deliver has failed.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
}

