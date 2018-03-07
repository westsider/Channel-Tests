//
//  ViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

// [ ] send tickers that pass ticker to mail as comma separated txt

//-------> take a break <--------
// [ ] add max positions to stats
// [ ] display % capital used
// [ ] largest drawdown, extra stats to main UI
// [ ] add distribution statis -> realm -> main UI
// [ ] limit update spy only after market closes!
// [ ] get alpha and scichart login
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
//        let alphaApiKey = "T8A2PPT26G83RF68"
//        UserDefaults.standard.set(alphaApiKey, forKey: "alphaApiKey")
//        
//        let licencing:String = "<LicenseContract>" +
//            "<Customer>Swift Sense</Customer>" +
//            "<OrderId>ABT171115-1656-88135</OrderId>" +
//            "<LicenseCount>1</LicenseCount>" +
//            "<IsTrialLicense>false</IsTrialLicense>" +
//            "<SupportExpires>11/15/2018 00:00:00</SupportExpires>" +
//            "<ProductCode>SC-IOS-2D-PRO</ProductCode>" +
//            "<KeyCode>364e0b1c08ae94c831328cb783064a526d8ca335a2cb9de59ca53352ae5ed1f01092defffaafec2fbf9800261297e78b5c6e1dc909af374f2f8db8e7996b06f16d55b7dcb3a4cbe34c386396e5ec55af702b90c19eb821ba267e856d724ba4592b8ab35d9a58114583e7ba7af11d8750530bdb965c0a23be79df43b95cb0e9f4cdc7fe1787a37b09751da452cc8dd62bd5e36304ea5c82c9c54d65a9a43472aa5b066762</KeyCode>" +
//        "</LicenseContract>"
//        
//        UserDefaults.standard.set(licencing, forKey: "scichartLicense")
        
        //MARK: - TODO - large data fails durring marlker hours..
        //  solve with compact get / replace. must include full data to start...
        alphaLink.checkRealmDatabase() //Prices().deleteOld()
        //alphaLink.getData(forTicker: "SPY", compact: false, debug: true) //force get data
        mainText.text = textForUI
        getStatsFromRealm()
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

