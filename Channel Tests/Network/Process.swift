//
//  Process.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/4/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class Process {

    class func httpStatus(service:String, httpStatus: Int, ticker:String ) -> String {
        
        weak var delegate: FirebaseDelegate?
        var message = " status code: \(httpStatus)"
        
        switch httpStatus {
        case 200:
            message += " Server: OK – Everything worked as expected "
        case 401:
            message += " Server: Unauthorized – Your User/Password API Keys are incorrect"
            Utilities().playErrorSound()
        case 403:
            message += " Server: You are not subscribed to the data feed requested for \(ticker)"
            Utilities().playErrorSound()
        case 404:
            message += " Server: Not Found – The end point requested is not available for \(ticker)"
            Utilities().playErrorSound()
        case 429:
            message += " Server: Too Many Requests – You have hit a limit. See Limits for \(ticker)"
            Utilities().playErrorSound()
        case 500:
            message += " Server: Internal Server Error – We had a problem. Try again later for \(ticker)."
            Utilities().playErrorSound()
        case 503:
            message += " Server: Unavailable – throttle limit or \(service) may be experiencing difficulties."
            Utilities().playErrorSound()
        default:
            message += " Server didn't handshake"
            Utilities().playErrorSound()
        }
        delegate?.changeUImessage(message: message)
        print("\n------------------------------------------------------------------\n")
        print(message)
        print("\n------------------------------------------------------------------\n")
        return message
    }
}
