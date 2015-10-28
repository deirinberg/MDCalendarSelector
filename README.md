# MDCalendarSelector

![Pod Version](https://img.shields.io/cocoapods/v/MDCalendarSelector.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/MDCalendarSelector.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/MDCalendarSelector.svg?style=flat)

`MDCalendarSelector` is a lightweight customizable view that allows you to easily select a range of dates.

## Installation

### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `MDCalendarSelector` in your projects. Simply add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'MDCalendarSelector'
```

### Manually

Drag the `MDCalendarSelector/MDCalendarSelector` folder into your project.

## Usage

(see sample Xcode project in `/Demo`)

Declare and initialize MDCalendarSelector like a normal view. Add an MDCalendarSelectorDelegate to your class to listen to changes to the selected date range.

```swift
  var calendarSelector = MDCalendarSelector();
  calendarSelector.delegate = self;
```

## Delegate Methods

```swift
  func calendarSelector(calendarSelector: MDCalendarSelector, startDateChanged startDate: NSDate)
  func calendarSelector(calendarSelector: MDCalendarSelector, endDateChanged endDate: NSDate)
```

## Customization

`MDCalendarSelector` can be customized by editing the following properties:

```swift
  var backgroundViewColor: UIColor // background color of the calendar, default is UIColor.blackColor()
  var highlightedColor: UIColor    // background color of header and of selected days, default is UIColor.redThemeColor()
  var dateTextColor: UIColor  // text color of days that can be selected, default is UIColor.whiteColor()
  var nextDateTextColor: UIColor  // text color of days that are in a different month, default is UIColor(white: 1.0, alpha: 0.5)
  var disabledTextColor: UIColor  // text color of days that are disabled, default is UIColor(white: 1.0, alpha: 0.3)
  var highlightedTextColor: UIColor // text color of selected days and header month, default is UIColor.whiteColor()
  var maxRange: UInt  // max amount of days that can be selected, default is 21
    
  var regularFontName: String?  // font name for all regular text, default font is the systemFont
  var boldFontName: String? // font name for all bold text, default font is the boldSystemFont
  var headerFontSize: CGFloat // font size for the headerLabel text, default is 15.0
  var dateFontSize: CGFloat  // font size for dates, default is 13.0
  ```
  
## Other Readable Properties
```swift
var startDate: NSDate // initial date of selected range
var endDate: NSDate // last date of selected range
var selectedLength: Int // length of selected date range
```

## Examples

`MDCalendarSelector` was initially used in an app I created, [In the Loop](https://itunes.apple.com/us/app/in-loop-discover-nearby-events/id921923681?ls=1&mt=8).
