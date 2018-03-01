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
//  [ ] use RxSwift to update UI
//  [ ] convert string to date
//  [ ] save to realm as WeeklyStats (stringDate, date, profit, cumProfit, winPct, cost, ROI , annualRoi?, ticker, stars)
//  [ ] market condition

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseLink().authAndGetFirebase() //  needs a completion handler
        
    }
    

}

