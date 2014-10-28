//
//  MDCalendarSelector.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 9/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import Foundation
//
//  MDCalendarSelector.swift
//  CalendarPicker
//
//  Created by Dylan Eirinberg on 7/10/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import UIKit
import QuartzCore

extension CGRect {
    var center: CGPoint {
        return CGPointMake(self.origin.x + self.size.width/2, self.origin.y + self.size.height/2)
    }
    var endX : CGFloat {
        return self.origin.x + self.size.width
    }
    var endY: CGFloat {
        return self.origin.y + self.size.height
    }
}

class MDCalendarSelector: UIControl, UIGestureRecognizerDelegate {
    var fontName: String?
    var selectedDates: Array<NSDate> = []
    var dateArray: Array<CalDate> = []
    var dateButtonArray: Array<CalDateButton> = []
    var today = CalDate(date: NSDate(), full: true, enabled: false)
    var weekdayArray = [NSLocalizedString("Sun", comment: "Sun"), NSLocalizedString("Mon", comment: "Mon"), NSLocalizedString("Tue", comment: "Tue"), NSLocalizedString("Wed", comment: "Wed"), NSLocalizedString("Thu", comment: "Thu"), NSLocalizedString("Fri", comment: "Fri"), NSLocalizedString("Sat", comment: "Sat")]
    var backgroundView = UIView()
    var box = UIView() //first row of dates
    var box2 = UIView() //second row and so on
    var box3 = UIView()
    var monthLabel = UILabel()
    var dayOfWeekView = UIView()
    var monthView = UIView()
    var lastIndicies = [-1, -1]
    var curMonthIndex: Int = -1
    var nextMonthIndex: Int = -1
    var start = 0, end = 0
    var monthsAhead = 0
    
    
    //these can be edited
    var textColor = UIColor.blackColor()  //text color of days that can be selected
    var disabledTextColor = UIColor.grayColor() //text color of disabled days
    var backgroundViewColor = UIColor.clearColor() //background color of calendar view
    var highlightedColor = UIColor(red: 241/255, green: 89/255, blue: 90/255, alpha: 1.0) //background color of header and of selected days
    var highlightedTextColor = UIColor.whiteColor() //text color of selected days
    
    var maxRange = 7    //max amount of days that can be selected, ranges 14 or under are supported
    let monthRange = 2  //max amount of months that calendar can go ahead to
    var fontSize: Double = 13  //relative font size of all elements
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, fontName: String){
        self.fontName = fontName
        backgroundView.layer.cornerRadius = 8.0
        super.init(frame: frame)
    }
    
    override init() {
        super.init(frame: CGRectZero)
    }
    
    func populate(date: NSDate, length: Int) {
        newMonth(CalDate(date: date, full: true, enabled: false), length: length-1)
    }
    
    
    func newMonth(date: CalDate, length: Int) {
        dateArray.removeAll(keepCapacity: false)
        dateButtonArray.removeAll(keepCapacity: false)
        
        let setDate = date.month == today.month ? today : date
        let calendar = NSCalendar(identifier: NSGregorianCalendar)!
        let components = calendar.components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: setDate.date)
        var thisDate = calendar.dateFromComponents(components)
        var offsetComponents = NSDateComponents()
        offsetComponents.day = 1-setDate.day
        let firstDate = CalDate(date: calendar.dateByAddingComponents(offsetComponents, toDate: thisDate!, options: nil)!, full: true, enabled: false)
        let precedingWeek = firstDate.dayOfWeekNum - 1 == 0
        let daysBefore = precedingWeek ? setDate.day + firstDate.dayOfWeekNum + 5 : setDate.day + firstDate.dayOfWeekNum - 2
        let daysAfter = 42-daysBefore
        
        for var offset = daysBefore; offset > 0; offset-- {
            offsetComponents.day = -offset
            let newDate = CalDate(date: calendar.dateByAddingComponents(offsetComponents, toDate: thisDate!, options: nil)!, full: true, enabled: today.month == firstDate.month)
            dateArray.append(newDate)
        }
        for var offset = 0; offset < daysAfter; offset++ {
            offsetComponents.day = offset
            var newDate = CalDate(date: calendar.dateByAddingComponents(offsetComponents, toDate: thisDate!, options: nil)!, full: true, enabled: false)
            newDate.enabled = monthsAhead == monthRange && newDate.month != firstDate.month
            dateArray.append(newDate)
        }
        
        var startIndex = -1
        let hGap = frame.size.width/8
        let xOffset = CGFloat(frame.width-hGap*7)/2
        let vGap = frame.size.height/10
        
        monthLabel.frame = CGRectMake(xOffset, 0, frame.size.width*0.875, frame.size.height*0.107)
        let monthMaskPath = UIBezierPath(roundedRect: monthLabel.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(8.0, 8.0))
        var monthMask = CAShapeLayer()
        monthMask.path = monthMaskPath.CGPath
        monthLabel.layer.mask = monthMask
        monthLabel.text = setDate.month
        monthLabel.backgroundColor = highlightedColor
        monthLabel.font = setFont(fontSize, max: fontSize + 2, bold: true)
        monthLabel.textColor = highlightedTextColor
        monthLabel.textAlignment = NSTextAlignment.Center
        addSubview(monthLabel)
        
        for index in 0..<countElements(weekdayArray) {
            var label = UILabel(frame: CGRectMake(CGFloat(index)*hGap, 0, hGap-5, vGap-10))
            label.text = weekdayArray[index]
            label.textAlignment = NSTextAlignment.Center
            label.font = setFont(fontSize - 2, max: fontSize, bold: true)
            label.textColor = textColor
            dayOfWeekView.addSubview(label)
        }
        
        dayOfWeekView.frame = CGRectMake(xOffset, monthLabel.frame.endY + frame.size.height*0.015, frame.size.width*0.875, frame.size.height*0.0604)
        addSubview(dayOfWeekView)
        
        for index in 0..<countElements(dateArray) {
            let (row, col) = (index % 7, Int(index/7))
            let newDate = dateArray[index]
            var button = UIButton(frame: CGRectMake(CGFloat(row)*hGap, CGFloat(col)*hGap, hGap-5, vGap))
            button.setTitle("\(newDate.day)", forState: .Normal)
            button.titleLabel?.font = setFont(fontSize - 2, max: fontSize, bold: false)
            button.setTitleColor(newDate.enabled ? disabledTextColor : textColor, forState: .Normal | .Disabled)
            button.enabled = false
            button.tag = index
            
            if date.month == newDate.month && date.day == newDate.day {
                startIndex = index
            }
            if newDate.month == firstDate.month && newDate.day == 1 {
                curMonthIndex = index
            }
            else if newDate.month != firstDate.month && newDate.day == 1 {
                nextMonthIndex = index
            }
            
            var selLayer = CALayer()
            
            let radius = min(button.frame.size.width, button.frame.size.height)*0.75
            let xOrigin = button.frame.origin.x + (button.frame.size.width-radius)/2
            let yOrigin = button.frame.origin.y + (button.frame.size.height-radius)/2
            selLayer.frame = CGRectMake(xOrigin, yOrigin, radius, radius)
            selLayer.cornerRadius = radius/2
            monthView.layer.insertSublayer(selLayer, below: button.layer)
            
            dateButtonArray.append(CalDateButton(button: button, layer: selLayer, date: newDate))
            monthView.addSubview(button)
        }
        
        monthView.frame = CGRectMake(xOffset, dayOfWeekView.frame.endY + frame.size.height*0.015, frame.size.width*0.875, frame.size.width*0.75)
        addSubview(monthView)
        
        backgroundView.frame = CGRectMake(xOffset, 0, frame.size.width*0.875, monthView.frame.endY+5)
        backgroundView.backgroundColor = backgroundViewColor
        insertSubview(backgroundView, belowSubview: monthLabel)
        
        if firstDate.month == today.month {
            dateButtonArray[daysBefore].button.titleLabel!.font = setFont(fontSize - 2, max: fontSize, bold: true)
        }
        
        startIndex = startIndex == -1 ? curMonthIndex : startIndex
        drawSelected(startIndex, end: startIndex+length)
    }
    
    func drawSelected(start: Int, end: Int) {
        if end < curMonthIndex {
            monthsAhead--
            clearAll()
            newMonth(dateArray[start], length: end-start)
            return
        }
        
        if start >= nextMonthIndex {
            monthsAhead++
            clearAll()
            newMonth(dateArray[start], length: end-start)
            return
        }
        
        self.start = start
        self.end = end
        
        clearSelected()
        
        for index in start...end {
            var calButton = dateButtonArray[index]
            selectedDates.append(calButton.date.date)
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
            calButton.selLayer.backgroundColor = highlightedColor.CGColor
            CATransaction.commit()
            
            calButton.button.setTitleColor(highlightedTextColor, forState: .Normal | .Disabled)
        }
        if start != end {
            var startButton = dateButtonArray[start]
            var line = end % 7 + 1
            var length = end - start
            var endButton = length >= 6 ? dateButtonArray[start + (6 - start % 7)] : end % 7 - start % 7 > 0 ? dateButtonArray[end] : dateButtonArray[end-line]
            
            var width = endButton.button.center.x - startButton.button.center.x
            var startY = startButton.button.frame.origin.y + (startButton.button.frame.size.height - startButton.selLayer.frame.size.height)/2
            box.hidden = false
            box.frame = CGRectMake(startButton.button.center.x, startY, width, startButton.selLayer.frame.size.height)
            box.backgroundColor = highlightedColor
            monthView.insertSubview(box, belowSubview: startButton.button)
            
            if (length <= 6 && end % 7 < start % 7) || length > 6 {
                startButton = length - line < 7 ? dateButtonArray[end-line+1] : dateButtonArray[end-line-6]
                endButton = length - line < 7 ? dateButtonArray[end] : dateButtonArray[start+6]
                width = endButton.button.center.x - startButton.button.center.x
                startY = startButton.button.frame.origin.y + (startButton.button.frame.size.height - startButton.selLayer.frame.size.height)/2
                box2.hidden = false
                box2.frame = CGRectMake(startButton.button.center.x, startY, width, startButton.selLayer.frame.size.height)
                box2.backgroundColor = highlightedColor
                monthView.insertSubview(box2, belowSubview: startButton.button)
                
                if (length - line) >= 7 {
                    startButton = dateButtonArray[end-line+1]
                    endButton = dateButtonArray[end]
                    width = endButton.button.center.x - startButton.button.center.x
                    startY = startButton.button.frame.origin.y + (startButton.button.frame.size.height - startButton.selLayer.frame.size.height)/2
                    box3.hidden = false
                    box3.frame = CGRectMake(startButton.button.center.x, startY, width, startButton.selLayer.frame.size.height)
                    box3.backgroundColor = highlightedColor
                    monthView.insertSubview(box3, belowSubview: startButton.button)
                }
            }
        }
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func clearSelected() {
        box.hidden = true
        box2.hidden = true
        box3.hidden = true
        selectedDates.removeAll(keepCapacity: false)
        for index in 0..<countElements(dateButtonArray) {
            var dateButton = dateButtonArray[index]
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
            dateButton.selLayer.backgroundColor = UIColor.clearColor().CGColor
            CATransaction.commit()
            
            dateButton.button.setTitleColor(dateButton.date.enabled ? disabledTextColor : textColor, forState: .Normal | .Disabled)
            
            if !dateArray[curMonthIndex].month.hasPrefix(dateButton.date.month) {
                dateButton.button.setTitleColor(disabledTextColor, forState: .Normal | .Disabled)
            }
        }
    }
    
    func clearAll() {
        lastIndicies = [-1, -1]
        box.removeFromSuperview()
        box2.removeFromSuperview()
        box3.removeFromSuperview()
        monthLabel.removeFromSuperview()
        
        for dateButton in dateButtonArray {
            dateButton.selLayer.removeFromSuperlayer()
            dateButton.button.removeFromSuperview()
        }
        
        monthView.removeFromSuperview()
    }
    
    func dateSelected(calButton: CalDateButton) {
        var index = calButton.button.tag
        
        if index == start || index == end {
            drawSelected(index, end: index)
        }
        else if start <= index && index <= end {
            drawSelected(start, end: index)
        }
        else if index+1 == start {
            (end-start) < (maxRange - 1) ? drawSelected(index, end: end) : drawSelected(start-1, end: end-1)
        }
        else if index-1 == end {
            (end-start) < (maxRange - 1) ? drawSelected(start, end: index) : drawSelected(start+1, end: end+1)
        }
        else {
            drawSelected(index, end: index)
        }
    }
    
    func setFont(cur: Double, max: Double, bold: Bool) -> UIFont {
        var font = fontName != nil ? UIFont(name: fontName!, size: scaledFont(cur, max: max))! : UIFont.systemFontOfSize(scaledFont(cur, max: max))
        
        if bold {
            if let name = fontName {
                if !name.hasSuffix("-Bold") {
                    font = UIFont(name: name + "-Bold", size: scaledFont(cur, max: max))!
                }
            }
            else {
                font = UIFont.boldSystemFontOfSize(scaledFont(cur, max: max))
            }
        }
        
        return font
    }
    
    func scaledFont(cur: Double, max: Double) -> CGFloat {
        let scaled = CGFloat(cur)*(frame.size.width/280)
        return min(scaled, CGFloat(max))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastIndicies = [-1, -1]
        touchesMoved(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var location = touches.anyObject()?.locationInView(self)
        
        if CGRectContainsPoint(monthView.frame, location!) {
            for dateButton in dateButtonArray {
                if !dateButton.date.enabled && dateButton.date.day != lastIndicies[0] && dateButton.date.day != lastIndicies[1] {
                    let curFrame = dateButton.button.frame
                    let buttonFrame = CGRectMake(curFrame.origin.x + monthView.frame.origin.x, curFrame.origin.y + monthView.frame.origin.y, curFrame.size.width, curFrame.size.height)
                    
                    if CGRectContainsPoint(buttonFrame, location!) {
                        lastIndicies.insert(dateButton.date.day, atIndex: 0)
                        lastIndicies.removeLast()
                        dateSelected(dateButton)
                        break
                    }
                }
            }
        }
    }
}

