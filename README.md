MDCalendarSelector
==================

Swift calendar component used in an app I created, [In the Loop](https://itunes.apple.com/us/app/in-loop-discover-nearby-events/id921923681?ls=1&mt=8), to select a range of dates.

Integrating MDCalendar into a project only requires a few lines of code, and there are many ways to customize it. Only 3 files (found in the source folder) need to be added. An example project demonstrates this.

![MDCalendar Recording](https://raw.githubusercontent.com/dylane629/MDCalendarSelector/master/Images/MDCalendarRecording.gif)

##Integrating MDCalendarSelector

MDCalendarSelector can be initialized with a frame and a font name to be used. The MDCalendarSelector can then be configured. Nothing will display until the MDCalendarSelector method ```populate(date: NSDate, length: Int)``` is called. The parameters date takes the starting date of the calendar (which will typically be set to the day of- NSDate()) and the amount of days to be initially selected. Setting a length up to 14 days is supported.

To get the dates the user selected, have the MDCalendarSelector variable add a target for value changed. When that is called, you can retrieve the dates from MDCalendarSelector's selectedDates (an array of NSDate's).


####MDCalendarSelector used in In the Loop
![MDCalendar Screenshot](https://raw.githubusercontent.com/dylane629/MDCalendarSelector/master/Images/InTheLoopScreenshot.png)


###Configurations
UIColor **backgroundViewColor**- changes color behind the main section of the calendar  
UIColor **highlightedColor**- background color of header and of selected days  
UIColor **textColor**- text color of days that can be selected  
UIColor **disabledTextColor**- text color of disabled days  
UIColor **highlightedTextColor**- text color of selected days and header month  

Int **maxRange**- max amount of days that can be selected (default is one week), up to 14 days are supported  
Int **monthRange**- max amount of months that calendar can go ahead to (default is 2)  
Double **fontSize**- relative font size of all elements  




