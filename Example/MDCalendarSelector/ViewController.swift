//
//  ViewController.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 9/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import UIKit
import PureLayout

class ViewController: UIViewController, MDCalendarSelectorDelegate {
    
    var containerView: UIView!
    var calendarSelector: MDCalendarSelector!
    var selectedDatesLabel: UILabel!
    var selectedLengthLabel: UILabel!
    var todayButton: UIButton!
    
    var didSetupConstraints: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView = UIView.newAutoLayoutView()
        view.addSubview(containerView)
        
        calendarSelector = MDCalendarSelector()
        calendarSelector.delegate = self
        calendarSelector.regularFontName = "Montserrat-Regular"
        calendarSelector.boldFontName = "Montserrat-Bold"
        containerView.addSubview(calendarSelector)

        selectedDatesLabel = UILabel.newAutoLayoutView()
        selectedDatesLabel.text = "No Selected Dates"
        selectedDatesLabel.textColor = UIColor(white: 0.0, alpha: 0.5)
        containerView.addSubview(selectedDatesLabel)
        
        selectedLengthLabel = UILabel.newAutoLayoutView()
        selectedLengthLabel.text = "(0 Days)"
        selectedLengthLabel.textColor = UIColor(white: 0.0, alpha: 0.5)
        containerView.addSubview(selectedLengthLabel)
        
        todayButton = UIButton(type: .System)
        todayButton.setTitle("Today", forState: .Normal)
        todayButton.setTitleColor(UIColor.themeRedColor(), forState: .Normal)
        todayButton.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        todayButton.addTarget(self, action: "todayButtonSelected", forControlEvents: .TouchUpInside)
        containerView.addSubview(todayButton)
        
        if #available(iOS 8.2, *) {
            selectedDatesLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightLight)
            selectedLengthLabel.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightUltraLight)
            
        } else {
            selectedDatesLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            selectedLengthLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 15.0)
        }
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            
            containerView.autoCenterInSuperview()
            
            calendarSelector.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            
            selectedDatesLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: calendarSelector, withOffset: 25.0)
            selectedDatesLabel
                .autoAlignAxisToSuperviewAxis(.Vertical)
            
            selectedLengthLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: selectedDatesLabel, withOffset: 10.0)
            selectedLengthLabel
                .autoAlignAxisToSuperviewAxis(.Vertical)
            
            todayButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: selectedLengthLabel, withOffset: 5)
            todayButton.autoAlignAxisToSuperviewAxis(.Vertical)
            todayButton.autoPinEdgeToSuperviewEdge(.Bottom)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }

    func calendarSelector(calendarSelector: MDCalendarSelector, startDateChanged startDate: NSDate) {
        
        updateSelectedDateLabel(startDate, endDate: calendarSelector.endDate)
    }
    
    func calendarSelector(calendarSelector: MDCalendarSelector, endDateChanged endDate: NSDate) {
        
        if let startDate = calendarSelector.startDate {
            updateSelectedDateLabel(startDate, endDate: endDate)
        }
    }
    
    func updateSelectedDateLabel(startDate: NSDate, endDate: NSDate?) {
        if let lastDate = endDate where
               startDate.dateString != lastDate.dateString {
            selectedDatesLabel.text = "\(startDate.displayDateString) - \(lastDate.displayDateString)"
        } else {
            selectedDatesLabel.text = "\(startDate.displayDateString)"
        }
        
        let length: Int = calendarSelector.selectedLength
        let daysText: String = length == 1 ? "Day" : "Days"
        
        selectedLengthLabel.text = "(\(length) \(daysText))"
    }
    
    func todayButtonSelected() {
        calendarSelector.goToToday()
    }
}

