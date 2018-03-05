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
// [ ] put spy in the top chart
// [ ] add stats to main vc
// [ ] display % capital used
// [ ] print tickers that pass ticker to mail
// [ ] completion handler for data fetch and processing
// [ ] use operation to thread http://iosbrain.com/blog/2018/03/04/concurrency-in-ios-introduction-to-the-abstract-operation-class-and-using-its-blockoperation-subclass-to-run-tasks-in-parallel/


import UIKit

class MainViewController: UIViewController, ClassBVCDelegate {

    @IBOutlet weak var updateText: UILabel!
    
    var firebaseLink = FirebaseLink()
    var stdBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    var optBacktest:[(date:Date, cost:Double, profit:Double, pos: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseLink.delegate = self
        
        
        
        getSPYData()
//        let dateToConvert  = "2017-12-19"
//        let _ = Utilities().convertToDateFrom(string: dateToConvert, debug: true)
        
//        let spyPrices = Prices().sortOneTicker(ticker: "SPY", debug: true)
//        print("Spy Dates counr \(spyPrices.count)")
        
    }
    
    func getSPYData() {
        Alpha().standardNetworkCall(ticker: "SPY", compact: true, debug: true) { (finished) in
            if finished {
                let spyPrices = Prices().sortOneTicker(ticker: "SPY", debug: true)
                print("Spy Dates count \(spyPrices.count)")
            }
        }
    }
    
    func readFirebase() {
        firebaseLink.authOnly()
        Statistics().getDistribution()
        stdBacktest = Statistics().standardBackTest(debug: false)
        optBacktest = Statistics().optimizedBackTest(debug: false)
        print("std count \(stdBacktest.count) opt coint \(optBacktest.count)")
        
    }
    func getFirebaseDataAndSpyData() {
        firebaseLink.authAndGetFirebase { (finished) in
            if finished {
                Statistics().getDistribution()
                self.stdBacktest = Statistics().standardBackTest(debug: false)
                self.optBacktest = Statistics().optimizedBackTest(debug: false)
                print("std count \(self.stdBacktest.count) opt coint \(self.optBacktest.count)")
                Alpha().standardNetworkCall(ticker: "SPY", compact: true, debug: true) { (finished) in
                    if finished {
                        let spyPrices = Prices().sortOneTicker(ticker: "SPY", debug: true)
                        print("Spy Dates counr \(spyPrices.count)")
                    }
                }
            }
        }
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

