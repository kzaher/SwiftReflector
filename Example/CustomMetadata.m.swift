//
//  CustomMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func relativeDate(from: AnyObject) -> AnyObject? {
    guard let stringDate = from as? String else {
        return nil
    }
    
    let dateFormatter = NSDateFormatter()

    guard let fromDate = dateFormatter.dateFromString(stringDate) else {
        return nil
    }
    
    return NSDate().timeIntervalSinceDate(fromDate)
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