//
//  MDCalendarSelector.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 10/26/15.
//  Copyright © 2015 Dylan Eirinberg. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

public protocol MDCalendarSelectorDelegate {
    
    func calendarSelector(calendarSelector: MDCalendarSelector, startDateChanged startDate: NSDate)
    func calendarSelector(calendarSelector: MDCalendarSelector, endDateChanged endDate: NSDate)
}

public class MDCalendarSelector: UIView {
    
    public var delegate: MDCalendarSelectorDelegate?
    
    // public variables
    
    // changes color behind the main section of the calendar
    public var backgroundViewColor: UIColor = UIColor.blackColor()
    
    // background color of header and of selected days
    public var highlightedColor: UIColor = UIColor.themeRedColor()
    
    // text color of days that can be selected
    public var dateTextColor: UIColor = UIColor.whiteColor()
    
    // text color of days that are in a different month
    public var nextDateTextColor: UIColor = UIColor(white: 1.0, alpha: 0.5)
    
    // text color of days that are disabled
    public var disabledTextColor: UIColor = UIColor(white: 1.0, alpha: 0.3)
    
    // text color of selected days and header month
    public var highlightedTextColor: UIColor = UIColor.whiteColor()
    
    // max amount of days that can be selected (default is 21 days), max is 28
    public var maxRange: UInt = 21
    
    // font name for all regular text
    public var regularFontName: String?
    
    // font name for all bold text
    public var boldFontName: String?

    // font size for the headerLabel text
    public var headerFontSize: CGFloat = 15.0
    
    // font size for dates
    public var dateFontSize: CGFloat = 13.0
    
    // public readonly variables
    
    public var startDate: NSDate? {
        get {
            if let date = prevMonthStartDate {
                return date
            }
            
            if startIndex == -1 {
                return nil
            }
            
            return dateFromDateLabelsIndex(startIndex)
        }
    }
    
    public var endDate: NSDate? {
        get {
            if let date = nextMonthEndDate {
                return date
            }
            
            if endIndex == -1 {
                return nil
            }
            
            return dateFromDateLabelsIndex(endIndex)
        }
    }
    
    public var selectedLength: Int {
        get {
            
            let calendar = NSCalendar.currentCalendar()
            let unit: NSCalendarUnit = .Day
            
            if let date = prevMonthStartDate {
                let components = calendar.components(unit, fromDate: date, toDate: endDate!, options: [])
                
                return components.day + 1
            }
            
            if let date = nextMonthEndDate {
                let components = calendar.components(unit, fromDate: startDate!, toDate: date, options: [])
                
                return components.day + 1
            }
            
            return endIndex - startIndex + 1
        }
    }
    
    // private variables (UI)
    
    private var headerView: UIView!
    private var headerLabel: UILabel!
    
    private var calendarView: UIView!
    private var weekdayLabelsContainerView: UIView!
    private var monthButtonsContainerView: UIView!
    
    private var boxViews: [MDBoxView] = []
    
    private var weekdayLabels: [UILabel] = []
    private var dateLabels: [UILabel] = []
    
    // private variables (data)
    
    private var startIndex: Int = -1 {
        didSet {
            if startIndex > 0 {
                prevMonthStartDate = nil
            }
            
            delegate?.calendarSelector(self, startDateChanged: startDate!)
        }
    }
    
    private var endIndex: Int = -1 {
        didSet {
            if endIndex < numDaysPerWeek*numRows - 1 {
                nextMonthEndDate = nil
            }
            
            delegate?.calendarSelector(self, endDateChanged: endDate!)
        }
    }
    
    private var lastSelectedIndex: Int = -1
    private var todayIndex: Int = -1
    
    private var todayDate: NSDate = NSDate()
    private var currentDate: NSDate = NSDate()
    private var currentYear: Int = -1
    
    private var prevMonthStartDate: NSDate?
    private var nextMonthEndDate: NSDate?

    private let numDaysPerWeek: Int = 7
    private let numRows: Int = 6
    
    private let numMonths: Int = 12
    private let maxMonthDays: Int = 31
    private let minMonthDays: Int = 28

    private var didSetupConstraints: Bool = false
    
    init(){
        super.init(frame: CGRectMake(0, 0, 300, 300))
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true

        headerView = UIView.newAutoLayoutView()
        headerView.backgroundColor = highlightedColor
        addSubview(headerView)
        
        headerLabel = UILabel.newAutoLayoutView()
        headerLabel.textColor = highlightedTextColor
        headerView.addSubview(headerLabel)
        
        calendarView = UIView.newAutoLayoutView()
        calendarView.backgroundColor = backgroundViewColor
        addSubview(calendarView)
        
        weekdayLabelsContainerView = UIView.newAutoLayoutView()
        calendarView.addSubview(weekdayLabelsContainerView)
        
        for i in 0...numDaysPerWeek {
            let dayOfWeekLabel = UILabel.newAutoLayoutView()
            
            switch(i) {
            case 0:
                dayOfWeekLabel.text = "Sun"
                break
            case 1:
                dayOfWeekLabel.text = "Mon"
                break
            case 2:
                dayOfWeekLabel.text = "Tue"
                break
            case 3:
                dayOfWeekLabel.text = "Wed"
                break
            case 4:
                dayOfWeekLabel.text = "Thu"
                break
            case 5:
                dayOfWeekLabel.text = "Fri"
                break
            case 6:
                dayOfWeekLabel.text = "Sat"
                break
            default: break
            }
            
            dayOfWeekLabel.textColor = highlightedTextColor
            dayOfWeekLabel.font = regularFontOfSize(dateFontSize)
            dayOfWeekLabel.textAlignment = .Center
            weekdayLabels.append(dayOfWeekLabel)
            
            weekdayLabelsContainerView
                .addSubview(dayOfWeekLabel)
        }
        
        monthButtonsContainerView = UIView.newAutoLayoutView()
        calendarView.addSubview(monthButtonsContainerView)
        
        for _ in 0..<numRows {
            let boxView = MDBoxView.newAutoLayoutView()
            boxView.backgroundColor = highlightedColor
            boxViews.append(boxView)
            monthButtonsContainerView.addSubview(boxView)
        }
        
        for _ in 0..<numDaysPerWeek*numRows {
            let label = UILabel.newAutoLayoutView()
            label.textAlignment = .Center
            label.layer.masksToBounds = true
            
            dateLabels.append(label)
            
            monthButtonsContainerView.addSubview(label)
        }
        
        currentYear = todayDate.year
        populateMonth(todayDate)
        
        updateConstraints()
    }
    
    override public func updateConstraints() {
        
        if !didSetupConstraints {
            headerView
                .autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            
            headerLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 8.0)
            headerLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 7.0)
            headerLabel
                .autoAlignAxisToSuperviewAxis(.Vertical)
            
            calendarView.autoPinEdge(.Top, toEdge: .Bottom, ofView: headerView)
            calendarView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
            
            weekdayLabelsContainerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            
            monthButtonsContainerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: weekdayLabelsContainerView)
            monthButtonsContainerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
            
            for i in 0..<boxViews.count {
                let boxView: MDBoxView = boxViews[i]
                let startLabel: UILabel = dateLabels[i*numDaysPerWeek]
                boxView.autoPinEdge(.Top, toEdge: .Top, ofView: startLabel)
                boxView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: startLabel)
            }
            
            for i in 0..<weekdayLabels.count {
                let label: UILabel = weekdayLabels[i]
                label.autoPinEdgeToSuperviewEdge(.Top, withInset: 5.0)
                label.autoPinEdgeToSuperviewEdge(.Bottom)
                
                if i % numDaysPerWeek == 0 {
                    label
                        .autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
                } else {
                    let prevLabel: UILabel = weekdayLabels[i - 1]
                    label.autoPinEdge(.Leading, toEdge: .Trailing, ofView: prevLabel, withOffset: 5)
                    label.autoMatchDimension(.Width, toDimension: .Width, ofView: prevLabel)
                }
                
                if i % numDaysPerWeek == numDaysPerWeek - 1 {
                    label
                        .autoPinEdgeToSuperviewEdge(.Trailing, withInset: 5)
                }
            }
            
            for i in 0..<dateLabels.count {
                let label: UILabel = dateLabels[i]
                if i % numDaysPerWeek == 0 {
                    label.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
                } else {
                    let prevLabel: UILabel = dateLabels[i-1]
                    label.autoPinEdge(.Leading, toEdge: .Trailing, ofView: prevLabel, withOffset: 5)
                    label.autoMatchDimension(.Width, toDimension: .Width, ofView: prevLabel)
                }
                
                if i % numDaysPerWeek == numDaysPerWeek - 1 {
                    label.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 5)
                }
                
                if i <= numRows {
                    label.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
                } else {
                    let aboveLabel: UILabel = dateLabels[i - numDaysPerWeek]
                    label.autoPinEdge(.Top, toEdge: .Bottom, ofView: aboveLabel)
                }
                
                if i > dateLabels.count - numDaysPerWeek {
                    label.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5)
                }
                
                label.autoMatchDimension(.Height, toDimension: .Width, ofView: label)
            }
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        for i in 0..<42 {
            let label: UILabel = dateLabels[i]
            label.layer.cornerRadius = 15
        }
    }
    
    private func populateMonth(date: NSDate) {
        currentDate = date
        currentYear = date.year
        
        let attributedDate: NSMutableAttributedString = NSMutableAttributedString(string: "\(date.monthString) \(date.year)", attributes: [NSFontAttributeName: boldFontOfSize(headerFontSize)])
        
        attributedDate.addAttribute(NSFontAttributeName, value: regularFontOfSize(headerFontSize), range: NSMakeRange(date.monthString.utf16.count, "\(date.year)".utf16.count + 1))
        
        headerLabel.attributedText = attributedDate
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components: NSDateComponents = calendar.components(NSCalendarUnit.Day, fromDate: date)
        
        let offsetComponents = NSDateComponents()
        offsetComponents.day = 1-components.day
        
        let calendarDate: NSDate = calendar.dateByAddingComponents(offsetComponents, toDate: date, options: NSCalendarOptions(rawValue: 0))!
        let additionalDays: Int = (calendarDate.dayOfWeekNum == 1) ? 7 : (calendarDate.dayOfWeekNum - 1)
        let daysBefore = (date.day - 1) + additionalDays
        
        let isCurrentMonth: Bool = date.dateString == NSDate().dateString
        if isCurrentMonth {
            todayIndex = daysBefore
        }
        
        for i in 0..<numDaysPerWeek*numRows {
            let dateLabel: UILabel = dateLabels[i]
            dateLabel.textColor = dateTextColor
            dateLabel.font = isCurrentMonth && i == todayIndex ? boldFontOfSize(dateFontSize) : regularFontOfSize(dateFontSize)
            
            if i < daysBefore {
                offsetComponents.day = -(daysBefore - i)
                let newDate = calendar.dateByAddingComponents(offsetComponents, toDate: date, options: .MatchFirst)!
                let newComponents: NSDateComponents = calendar.components(NSCalendarUnit.Day, fromDate: newDate)
                dateLabel.text = "\(newComponents.day)"
            }
            else if i > daysBefore {
                offsetComponents.day = i - daysBefore
                let newDate = calendar.dateByAddingComponents(offsetComponents, toDate: date, options: .MatchFirst)!
                let newComponents: NSDateComponents = calendar.components(NSCalendarUnit.Day, fromDate: newDate)
                
                dateLabel.text = "\(newComponents.day)"
            }
            else {
                dateLabel.text = "\(date.day)"
                dateLabel.textColor = dateTextColor
            }
            
            if currentDate.month == todayDate.month && currentDate.year == todayDate.year {
                if i < daysBefore {
                    dateLabel.textColor = disabledTextColor
                }
                else if dateNextMonth(i) {
                    dateLabel.textColor = nextDateTextColor
                }
                
            } else if datePrevMonth(i) || dateNextMonth(i) {
                dateLabel.textColor = nextDateTextColor
            }
        }
    }
    
    private func buttonSelected(index: Int) {
        if startIndex == -1 || index < startIndex {
            startIndex = index
        }
        else if endIndex == -1 || index > endIndex {
            endIndex = index
        }
        
        if endIndex == -1 {
            endIndex = startIndex
        }
        
        if index > startIndex && index < endIndex {
            endIndex = index
        }
        
        let range: Int = Int(maxRange)
        if selectedLength > range && index >= endIndex {
            incrementPrevMonthStartDate(selectedLength - range)

            if prevMonthStartDate == nil {
                startIndex = endIndex - range + 1
            } else {
                delegate?.calendarSelector(self, startDateChanged: startDate!)
            }
            
        }
        
        if selectedLength > range && index <= startIndex {
            decrementNextMonthEndDate(selectedLength - range)
            
            if nextMonthEndDate == nil {
                endIndex = startIndex + range - 1
            } else {
                delegate?.calendarSelector(self, endDateChanged: endDate!)
            }
        }
        
        if todayDate.month == currentDate.month && todayDate.year == currentDate.year {
            startIndex = max(startIndex, todayIndex)
            endIndex = max(endIndex, todayIndex)
        }
        
        if index != lastSelectedIndex {
            lastSelectedIndex = -1
        }
        
        let startRow: Int = startIndex/numDaysPerWeek
        let endRow: Int = endIndex/numDaysPerWeek
        
        for i in 0..<boxViews.count {
            let boxView: MDBoxView = boxViews[i]
            boxView.leadingConstraint?.autoRemove()
            boxView.trailingConstaint?.autoRemove()
            
            if selectedLength > 1 {
                if i == startRow {
                    let startLabel: UILabel = dateLabels[startIndex]
                    boxView.leadingConstraint = boxView.autoPinEdge(.Leading, toEdge: .Leading, ofView: startLabel, withOffset: startLabel.bounds.size.width/2)
                }
                else if i > startRow && i <= endRow {
                    let firstColumnLabel: UILabel = dateLabels[i*numDaysPerWeek]
                    boxView.leadingConstraint = boxView.autoPinEdge(.Leading, toEdge: .Leading, ofView: firstColumnLabel, withOffset: firstColumnLabel.bounds.size.width/2)
                }
                
                if i == endRow {
                    let endLabel: UILabel = dateLabels[endIndex]
                    boxView.trailingConstaint?.autoRemove()
                    boxView.trailingConstaint = boxView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: endLabel, withOffset: -endLabel.bounds.size.width/2)
                }
                else if i < endRow && i >= startRow {
                    let lastColumnLabel: UILabel = dateLabels[i*numDaysPerWeek + numDaysPerWeek-1]
                    boxView.trailingConstaint = boxView.autoPinEdge(.Trailing, toEdge: .Trailing, ofView: lastColumnLabel, withOffset: -lastColumnLabel.bounds.size.width/2)
                }
            }
            
            if i >= startRow && i <= endRow {
                boxView.backgroundColor = highlightedColor
            } else {
                boxView.backgroundColor = UIColor.clearColor()
            }
        }
        
        for i in 0..<dateLabels.count {
            let button = dateLabels[i]
            if i >= startIndex && i <= endIndex {
                button.backgroundColor = highlightedColor
            } else {
                button.backgroundColor = UIColor.clearColor()
            }
        }
        
        layoutIfNeeded()
    }
    
    private func datePrevMonth(index: Int) -> Bool {
        let dateLabel: UILabel = dateLabels[index]
        
        if let text = dateLabel.text {
            let day = Int(text)!
            let prevMonthMinCount: Int = minMonthDays - (numDaysPerWeek*numRows-maxMonthDays)
            let minIndex: Int = numDaysPerWeek*2 - 1
            
            if index <= minIndex && day >= prevMonthMinCount {
                return true
            }
        }
        
        return false
    }
    
    private func dateNextMonth(index: Int) -> Bool {
        let dateLabel: UILabel = dateLabels[index]
        if let text = dateLabel.text {
            let day = Int(text)!
            
            let nextMonthMaxCount: Int = numDaysPerWeek*numRows-minMonthDays
            let maxIndex: Int = numDaysPerWeek*numRows - nextMonthMaxCount
            
            if index >= maxIndex && day <= nextMonthMaxCount {
                return true
            }
        }
        
        return false
    }
    
    private func incrementPrevMonthStartDate(change: Int) {
        if let date = prevMonthStartDate {
            prevMonthStartDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: abs(change), toDate: date, options: NSCalendarOptions(rawValue: 0))
            
            let firstMonthDate: NSDate = dateFromDateLabelsIndex(0)
            
            if prevMonthStartDate!.compare(firstMonthDate) != .OrderedAscending {
                prevMonthStartDate = nil
            }
        }
    }
    
    private func decrementNextMonthEndDate(change: Int) {
        if let date = nextMonthEndDate {
            nextMonthEndDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -abs(change), toDate: date, options: NSCalendarOptions(rawValue: 0))
            
            let endMonthDate: NSDate = dateFromDateLabelsIndex(dateLabels.count - 1)
            
            if nextMonthEndDate!.compare(endMonthDate) != .OrderedDescending {
                nextMonthEndDate = nil
            }
        }
    }
    
    private func dateFromDateLabelsIndex(index: Int) -> NSDate {
        let dateLabel: UILabel = dateLabels[index]
       
        var month: Int = currentDate.month
        var year: Int = currentDate.year
        if dateNextMonth(index) {
            if month == numMonths {
                month = 1
                year++
            } else {
                month++
            }
        } else if datePrevMonth(index) {
            if month == 1 {
                month = numMonths
                year--
            } else {
                month--
            }
        }
        
        let dateString: String = "\(year)-\(month)-\(dateLabel.text!)"
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.dateFromString(dateString)!
    }
    
    public func goToToday() {
        populateMonth(todayDate)
        startIndex = todayIndex
        endIndex = todayIndex
        buttonSelected(endIndex)
    }
    
    private func regularFontOfSize(size: CGFloat) -> UIFont {
        if let fontName = regularFontName,
            let font = UIFont(name: fontName, size: size) {
                return font
        }
        
        return UIFont.systemFontOfSize(size)
    }
    
    private func boldFontOfSize(size: CGFloat) -> UIFont {
        if let fontName = boldFontName,
            let font = UIFont(name: fontName, size: size) {
                return font
        }
        
        return UIFont.boldSystemFontOfSize(size)
    }
    
    // touch handling
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved(touches, withEvent: event)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInView(monthButtonsContainerView) {
            if CGRectContainsPoint(monthButtonsContainerView.frame, location) {
                for i in 0..<dateLabels.count {
                    let label: UILabel = dateLabels[i]
                    if CGRectContainsPoint(label.frame, location) {
                        buttonSelected(i)
                        return
                    }
                }
            }
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInView(monthButtonsContainerView) {
            
            let minDateLabel: UILabel = dateLabels[0]
            let maxDateLabel: UILabel = dateLabels[dateLabels.count - 1]
            
            let relativeLocationX: CGFloat = min(max(location.x, minDateLabel.center.x), maxDateLabel.center.x)
            let relativeLocationY: CGFloat = min(max(location.y, minDateLabel.center.y), maxDateLabel.center.y)
            let relativeLocation: CGPoint = CGPointMake(relativeLocationX, relativeLocationY)
            
            for i in 0..<dateLabels.count {
                let label: UILabel = dateLabels[i]
                if CGRectContainsPoint(label.frame, relativeLocation) {
                    if i < todayIndex && currentDate.month == todayDate.month && currentDate.year == todayDate.year {
                        return
                    }
                    
                    let firstDate: NSDate = dateFromDateLabelsIndex(numDaysPerWeek)
                    let lastDate: NSDate = dateFromDateLabelsIndex(numDaysPerWeek*numRows - 1)
                    let date: NSDate = dateFromDateLabelsIndex(i)
                    if date.month != currentDate.month || date.year != currentDate.year {
                        
                        let length = endIndex - startIndex
                        prevMonthStartDate = startDate
                        nextMonthEndDate = endDate

                        if date.compare(currentDate) == .OrderedDescending {
                            endIndex = (lastDate.day >= 7 && i >= numDaysPerWeek*(numRows - 1)) ? date.dayOfWeekNum - 1 + numDaysPerWeek : date.dayOfWeekNum - 1
                            startIndex = max(endIndex - length, 0)
                            
                        } else {
                            let start = numDaysPerWeek*numRows - (numDaysPerWeek - date.dayOfWeekNum) - 1
                            startIndex = (firstDate.day == 1) ? start - numDaysPerWeek : start
                            endIndex = min(startIndex + length, numDaysPerWeek*numRows - 1)
                        }
                        
                        let populateDate: NSDate = date.month == todayDate.month && date.year == todayDate.year ? todayDate : date
                        populateMonth(populateDate)

                        buttonSelected(endIndex)
                        
                        delegate?.calendarSelector(self, startDateChanged: startDate!)
                        delegate?.calendarSelector(self, endDateChanged: endDate!)
                        
                        return
                    }
                    
                    if i == lastSelectedIndex {
                        startIndex = i
                        endIndex = i
                        buttonSelected(i)
                        lastSelectedIndex = -1
                    }
                    
                    lastSelectedIndex = i
                    
                    return
                }
            }
        }
    }
}