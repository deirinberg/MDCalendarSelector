//
//  NSDate+MDCalendarSelector.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 10/19/15.
//  Copyright © 2015 Dylan Eirinberg. All rights reserved.
//

import Foundation

extension NSDate {
    public var dayOfWeekNum: Int {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "ee"
            return Int(dateFormatter.stringFromDate(self))!
        }
    }
    
    public var month: Int {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM"
            return Int(dateFormatter.stringFromDate(self))!
        }
    }
    
    public var monthString: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.stringFromDate(self)
        }
    }
    
    public var shortMonthString: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.stringFromDate(self)
        }
    }
    
    public var day: Int {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "d"
            return Int(dateFormatter.stringFromDate(self))!
        }
    }
    
    public var dateString: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.stringFromDate(self)
        }
    }
    
    public var displayDateString: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE M/dd/yy"
            return dateFormatter.stringFromDate(self)
        }
    }
    
    public var year: Int {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy"
            return Int(dateFormatter.stringFromDate(self))!
        }
    }
}
