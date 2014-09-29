//
//  CalDate.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 9/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import Foundation

struct CalDate {
    let dayOfWeekNum: Int
    let date: NSDate
    let month: String
    let day: Int
    var enabled: Bool
    var formattedDate: String
    
    init(date: NSDate, full: Bool, enabled: Bool){
        self.date = date
        self.enabled = enabled
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "e"
        dayOfWeekNum = dateFormatter.stringFromDate(date).toInt()!
        
        dateFormatter.dateFormat = full ? "MMMM" : "MMM"
        month = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "d"
        day = dateFormatter.stringFromDate(date).toInt()!
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        formattedDate = dateFormatter.stringFromDate(date)
    }
}
