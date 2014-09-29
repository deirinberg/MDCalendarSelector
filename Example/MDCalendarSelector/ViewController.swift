//
//  ViewController.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 9/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var dates: Array<NSDate> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        var date = NSDate()
        var dateView = MDCalendarSelector(frame: CGRectMake(0, 100, 300, 298), fontName: "Montserrat")
        dateView.center = UIScreen.mainScreen().bounds.center
        dateView.backgroundViewColor = UIColor.blackColor()
        dateView.disabledTextColor = UIColor.lightGrayColor()
        dateView.textColor = UIColor.whiteColor()
        dateView.populate(date, length: 7)
        dateView.addTarget(self, action: "datesChanged:", forControlEvents: .ValueChanged)
        view.addSubview(dateView)
    }
    
    func datesChanged(sender: MDCalendarSelector) {
        dates = sender.selectedDates
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

