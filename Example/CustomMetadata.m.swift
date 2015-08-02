//
//  CustomMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let seconds = 60
let minutes = 60 * seconds
let hours = 60 * minutes

let days = 24 * hours
let years = 365 * days

func relativeDate(from: AnyObject?) throws -> Int {
    guard let stringDate = from as? String else {
        throw NSError(domain: "Can't convert date", code: -1, userInfo: nil)
    }
    
    let dateFormatter = NSDateFormatter()

    guard let fromDate = dateFormatter.dateFromString(stringDate) else {
        throw NSError(domain: "Can't convert date", code: -1, userInfo: nil)
    }
    
    return Int(floor(NSDate().timeIntervalSinceDate(fromDate) / NSTimeInterval(years)))
}

// I wasn't kidding about april first
extension NSDate {
    class var isAprilFirst: Bool {
        let now = NSDate()
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Day.union(NSCalendarUnit.Month), fromDate: now)
        
        return components.month == 4 && components.day == 1
    }
}

class Silly { }
class Nothing {}