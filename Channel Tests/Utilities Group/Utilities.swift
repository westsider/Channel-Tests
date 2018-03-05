//
//  Utilities.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/1/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import RealmSwift
class Utilities {
    
    //MARK: - Date util
    let formatter = DateFormatter()
    let today = Date()
    
    func convertToDateFrom(string: String, debug: Bool)-> Date {
        if ( debug ) { print("\ndate from is string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "yyyy/MM/dd"
        let date:Date = formatter.date(from: dateS)!
        if ( debug ) { print("Convertion to Date: \(date)\n") }
        return date
    }
    
    func convertToDateFromNT(string: String, debug: Bool)-> Date? {
        if ( debug ) { print("\ndate from is string: \(string)") }
        let dateS    = string
        formatter.dateFormat = "MM/dd/yyyy"
        if let date:Date = formatter.date(from: dateS) {
            if ( debug ) { print("Convertion to Date: \(date)\n") }
            return date
        } else {
            if ( debug ) { print("Convertion to Date HAS FAILED!!!\n") }
            return nil
        }
    }
    
    func convertToStringFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    func convertToStringNoTimeFrom(date: Date)-> String {
        formatter.dateFormat = "MM/dd/yy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
    
    func lastUpdateWasToday(ticker:String, debug: Bool) -> Bool {
        let calendar = NSCalendar.current
        var answer:Bool = false
        let realm = try! Realm()
        if let lastUpdate = realm.objects(Prices.self).filter("ticker == %@", ticker)
            .sorted(byKeyPath: "date", ascending: true).last  {

                if let lastDate = lastUpdate.date {
                    if (calendar.isDateInToday(lastDate)) {
                        answer =  true
                        if ( debug ) { print("\ntoday is \(Utilities().convertToStringNoTimeFrom(date: today)) and lastUpdate was \(lastUpdate.dateString)\nit's \(answer) that we are current")
                    }
                }
            }
        }
        return answer
    }
    
    //MARK: - Dollar util
    func dollarStr(largeNumber:Double )->String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:Int(largeNumber)))!
    }
    
    func decimalStr(input:Double, Decimals:Int)->String {
        return String(format: "%.\(Decimals)f", input)
    }
    
    func getUser()-> (user:String, password:String) {
        var user = ""
        var password = ""
        if  let myUser = UserDefaults.standard.object(forKey: "user")   {
            user = myUser as! String
        } else {
            print("No User Set")
        }
        if  let myPassWord = UserDefaults.standard.object(forKey: "password")  {
            password = myPassWord as! String
        } else {
            print("No Password Set")
        }
        return (user:user, password:password)
    }
    
    func playAlertSound() {
        let systemSoundId: SystemSoundID = 1106 // connect to power // 1052 tube bell //1016 tweet
        AudioServicesPlaySystemSound(systemSoundId)
    }
    
    func playErrorSound() {
        let systemSoundId: SystemSoundID = 1052 // connect to power // 1052 tube bell //1016 tweet
        AudioServicesPlaySystemSound(systemSoundId)
    }
}
