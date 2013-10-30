STATUS
============
I receive alot of emails regarding this module and the incompatibility with iOS 7, so I've started fixing the problems.
Be patient with me :-)

AGCalendar Module <img src="http://f.cl.ly/items/422Q2T3G043h0O171E1z/acgLogo.png" height="35" valign="bottom" />
============


[![endorse](http://api.coderwall.com/chrisrm/endorsecount.png)](http://coderwall.com/chrisrm)

## Changelog
**Feb 8, 2013**		
* Added `Ti.Calendar.fetchEvents(object[startDate, endDate])`    
* Added `Ti.Calendar.fetchEvent(ids[identifier])`    
* Added `Ti.Calendar.deleteEvent(ids[identifier])`    
* Added [QA][] page for various questions and answers      
* Added `Ti.Calendar.hasCalendarAccess`

**Jan 9, 2013**		
* Fix for [#23][]	

**Jan 2, 2013**  
* Added eventlistener "longpress"  
* [Added VoiceOver/Accessibility support][]  
* Updated docs    

**Dec 16, 2012**  
* Added more details in the UITableView, including start date, end date and a subtitle using the events location)  
* alarmOffset now returned to each event having an alarm set


For a more detailed changelog, check the [Commit History][]

## Description
AGCalendar enables you to access the native calendar on your iPhone, iPad or iPod. EventKit and Core Data are both supported data sources. This enables you to switch between iCal and your custom calendar. Some more information below.

* **EventKit**: All events including the events in your native calendar will be shown. Events added will also be added to your native iCal.
* **CoreData**: Uses Core Data to store your calendar-events. Only events added by your application will be shown. Added events will not be added to iCal. This also allows you to add more details to your events. 

> <img src="http://f.cl.ly/items/1h3O0S3p2T0f1K2G2h1w/info1.png" height="228" style="margin-right:20px;" />


Accessing the Calendar Module
--------------------------

To access this module from JavaScript, you would do the following:

>     Titanium.Calendar = Ti.Calendar = require("ag.calendar");

Methods
--------
## `Ti.Calendar.dataSource(ids[string])`
This will set the data source you want to use.    
If this is not set, the calendar will default to EventKit as your data source.     

Please read the  *description* above for more information.

### Argument
* [string] **dataSource**: *eventkit* or *coredata* (Default: eventkit)

### Example
>     Ti.Calendar.dataSource("coredata");

## `Ti.Calendar.createView(object)`
This will create a calendarView with controls to move back an forth between months.

### Arguments
* [boolean] **editable**: Turns "swipe-to-delete" on or off. Defaults to  *false*
* [string] **color**: This is required by Titanium for some reason. Just set it to "*white*"

### Example
>     var calendarView = Ti.Calendar.createView({
		top: 0,
		editable: true,
		color: "white"
	});



## `Ti.Calendar.addEvent(object)`
This will add an event to your calendar object.
### Parameters
* **EventKit**   

 * [string] **title**: Event title
 * [string] **location**: Events location.
 * [string] **note**: Event notes.
 * [date] **startDate**: Events start. (Javascript date object)
 * [date] **endDate**: Events end. (Javascript date object) 
 * [object] **recurrence**: Recurrence rule (**EventKit only**)
 * [object] **alarm**: Event alarm (**EventKit only**)

* **Core Data** (Including the above)      

 * [string] **type**: Event type. E.g: *public* or *private*
 * [string] **attendees**: Comma-separated list of attendees
 * [string] **identifier**: Event identifier.
 * [string] **organizer**: Name of the organizer

### Example
>     var endDate = new Date();
	endDate.setHours(endDate.getHours()+3); // Set event to last 3 hours.

>     // Date to end our recurring event
	var recurringEnd = new Date();
	recurringEnd.setMonth(recurringEnd.getMonth()+6); // Recurring ends in 6 months

>     calendar.addEvent({
        title: "Attend the 2011 WWDC conference",   
        startDate: new Date(),  
        endDate: endDate,   
        location: "San Francisco",   
        identifier: Ti.Calendar.identifier,
        type:"public",
        attendees: "Steve, Phil",
        organizer: "Chris Magnussen",
        note: "Be mad about not getting the iPhone 5",
        recurrence: {
	         frequency: "month", // day, week, month, year
	         interval: 1,
	         end: recurringEnd
        },
        alarm: {
        	offset: -900 // 15 minutes before startDate
        }
    });

## `calendarView.selectTodaysDate([void])`
Select todays date in the calendarView.     
Nothing more, nothing less..

### Example

>     var calendarView = Ti.Calendar.createView();
>     var todayButton = Ti.UI.createButton({title: "Today"});

>     todayButton.addEventListener("click", function() {
        calendarView.selectTodaysDate();
    });

>     window.setLeftNavButton(todayButton);

## `calendarView.selectDate(ids[date])`
Programatically set active date.

### Example

>     var calendarView = Ti.Calendar.createView();
>     var dateButton = Ti.UI.createButton({title: "Set custom date"});

>     dateButton.addEventListener("click", function() {
        var newDate = new Date();
		// Add 3 days to current date
		newDate.setDate(newDate.getDate()+3);
		
>		  calendarView.selectDate(newDate);
	});

>     window.setLeftNavButton(dateButton);

## `Ti.Calendar.fetchEvents(object)`
Fetches an array containing events between dates. Useful if you dont want to use the Calendar View.

### Parameters
 * [date] **fromDate**: From date (Javascript date object) (*)
 * [date] **toDate**: To date (Javascript date object) (*)

\* Optional. If no from or toDate is present, [distantPast][] and [distantFuture][] is used.
 
### Example
>	  var from = new Date();
>	  from.setDate(from.getDate()-1);
>	  
>     var Events = Ti.Calendar.getEvents({
>         fromDate: from,
>         toDate: new Date()
>     });
>     
	for (var i=0;i<Events.length;i++) {
		Ti.API.info(Events[i].title);
	}

### Returns
* [string] **title**
* [string] **type** (*)
* [string] **note** (*)
* [string] **location**
* [string] **attendees** (*)
* [string] **description** (*)
* [string] **identifier** (**)
* [string] **organizer** (*)
* [date] **startDate** (Standard dateTime format)
* [date] **endDate** (Standard dateTime format)
* [float] **alarmOffset** (Seconds) (EventKit only)

(*) Only available when using Core Data as the data source.    
(**) When using Core Data your custom identifier is returned, else the auto generated eventIdentifier in EventKit is returned.


## `Ti.Calendar.fetchEvent(ids[identifier])`
Fetches details of a given event, based on the identifier.
 
### Example
>	  var Event = Ti.Calendar.fetchEvent("baedff11f74a256bfbca4336e38c6483");
	Ti.API.info(JSON.stringify(Event));

### Returns
* [string] **title**
* [string] **type** (*)
* [string] **note** (*)
* [string] **location**
* [string] **attendees** (*)
* [string] **description** (*)
* [string] **identifier** (**)
* [string] **organizer** (*)
* [date] **startDate** (Standard dateTime format)
* [date] **endDate** (Standard dateTime format)
* [float] **alarmOffset** (Seconds) (EventKit only)

(*) Only available when using Core Data as the data source.    
(**) When using Core Data your custom identifier is returned, else the auto generated eventIdentifier in EventKit is returned.

## `Ti.Calendar.deleteEvent(ids[identifier])`
Programmatically delete event by identifier.
 
### Example
>	  Ti.Calendar.deleteEvent("baedff11f74a256bfbca4336e38c6483");

Properties
--------
## `Ti.Calendar.identifier (read-only)`

This can be used for the ***identifier***-parameter in the *createView()*-instance. 

### Returns
* [string] MD5 sum of globallyUniqueString

## `Ti.Calendar.hasCalendarAccess (read-only)`

Used to check whether the user has granted access to the built-in calendar(EventKit)    
_Added in version 1.2.8_

### Returns
* [boolean] true or false



Events
-----
## `event:clicked`
When adding this to the calendar-view you will get all event-data in a single array whenever a user clicks the event-table.

### Returns
* [string] **title**
* [string] **type** (*)
* [string] **location**
* [string] **attendees** (*)
* [string] **description** (*)
* [string] **identifier** (**)
* [string] **organizer** (*)
* [date] **startDate** (Standard dateTime format)
* [date] **endDate** (Standard dateTime format)
* [float] **alarmOffset** (Seconds) (EventKit only)

(\*) Only available when using Core Data as the data source.   
(\**) When using Core Data your custom identifier is returned, else the auto generated eventIdentifier in EventKit is returned.

### Example
>     calendarView.addEventListener("event:clicked", function(e) {
        var event = e.event;
        var start_date = new Date(event.startDate);
        alert(event.title+" will start "+start_date);
    });

## `date:clicked`
Know which date/tile has been touched.

### Returns
* [date] **date** (Standard dateTime format)

### Example
>     calendarView.addEventListener("date:clicked", function(e) {
		var date_clicked = new Date(e.event.date);
		Ti.API.info("Date clicked: "+monthNames[date_clicked.getMonth()]+" "+date_clicked.getDate()	+".");
	});

## `date:longpress`
Fires whenever a datetile is pressed 0.5 seconds or more. Could be used to allow users to add events to the calendar by longpressing the day of month they want an event to be added. 

Requested by Digitalico - [Issue #22][]

### Returns
* [date] **date** (Standard dateTime format)

### Example
>     calendarView.addEventListener("date:longpress", function(e) {
		var date_clicked = new Date(e.event.date);
		var dialog = Ti.UI.createAlertDialog({
	    	message: "Would you like to add a new event on "+monthNames[date_clicked.getMonth()]+" "+date_clicked.getDate()+". ?",
	    	buttonNames: ['Yeah!', 'Cancel'],
			cancel: 1,
	    	title: 'New event'
		});
		dialog.addEventListener('click', function(e){
			Ti.API.info(e.index == 0 ? "Add event functionality..." : "No event added");
		});
		dialog.show();
	});


## `month:next`
Fires whenever the month is changed

### Returns
* [date] **date** (Standard dateTime format) (*)

(\*) Coming in 1.2.6. Currently not returning anything, just fires the event.

### Example
>     calendarView.addEventListener("month:next", function() {
		Ti.API.info("Going to next month");
	});
	
## `month:previuos`
Fires whenever the month is changed

### Returns
* [date] **date** (Standard dateTime format) (*)

(\*) Coming in 1.2.6. Currently not returning anything, just fires the event.

### Example
>     calendarView.addEventListener("month:previous", function() {
		Ti.API.info("Going back to previous month");
	});

## Usage

See example.

## Author

Chris Magnussen for Appgutta, DA.

 * [Twitter][]
 * [Appgutta.no][]

License
------
Copyright(c) 2013 Appgutta, DA. Please see the LICENSE file included in the distribution for further details.  

This module uses [klazuka][]'s calendar component. 


[Twitter]: http://twitter.com/crmag
[Appgutta.no]: http://www.appgutta.no
[Issue #22]: https://github.com/Appgutta/AGCalendar/issues/22
[Added VoiceOver/Accessibility support]: https://github.com/klazuka/Kal/commit/50b02e2d916343e46272dd8720a32fd5de615892
[klazuka]: https://github.com/klazuka/Kal/
[Commit History]: https://github.com/Appgutta/AGCalendar/commits/master
[#23]: http://github.com/Appgutta/AGCalendar/issues/23
[QA]: https://github.com/Appgutta/AGCalendar/wiki/QA
[distantFuture]: http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/Reference/Reference.html#//apple_ref/occ/clm/NSDate/distantFuture
[distantPast]: http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/Reference/Reference.html#//apple_ref/occ/clm/NSDate/distantPast
