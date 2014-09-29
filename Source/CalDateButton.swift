//
//  CalDateButton.swift
//  MDCalendarSelector
//
//  Created by Dylan Eirinberg on 9/28/14.
//  Copyright (c) 2014 Dylan Eirinberg. All rights reserved.
//

import UIKit

struct CalDateButton {
    var button: UIButton
    var selLayer: CALayer
    var date: CalDate
    
    init(button: UIButton, layer: CALayer, date: CalDate) {
        self.button = button
        selLayer = layer
        self.date = date
    }
}