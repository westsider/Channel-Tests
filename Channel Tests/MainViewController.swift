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

class MainViewController: UIViewController, FirebaseDelegate, AlphaDelegate {

    @IBOutlet weak var updateText: UILabel!
    
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
        readStatsFromRealm() // this stays here at launc with completion handler and UI update, fix this blocks UI
   
    }
    
    func getFirebaseData() {
        firebaseLink.authAndGetFirebase { (finished) in
            if finished {
                self.readStatsFromRealm()
            }
        }
    }
    
    func readStatsFromRealm() {
        
//        stdBacktest = Statistics().standardBackTest(debug: false, completion: )
//        optBacktest = Statistics().optimizedBackTest(debug: false)
        Statistics().getDistribution()
        print("std count \(stdBacktest.count) opt coint \(optBacktest.count)")
    }
    

    @IBAction func statsButtonAction(_ sender: UIButton) {
        segueToStats()
    }
    
    func changeUImessage(message: String) {
        print("\nMESSAGE FROM Firebase: \(message)");
        DispatchQueue.main.async {
            self.updateText.text = message
        }
    }
    
    func changeUImessageAlpha(message:String) {
        print("\nMESSAGE FROM Alpha: \(message)");
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

