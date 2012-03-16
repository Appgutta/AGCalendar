AGCalendar Module <img src="http://f.cl.ly/items/422Q2T3G043h0O171E1z/acgLogo.png" height="35" valign="bottom" />
============
## Description
AGCalendar enables you to access the native calendar on your iPhone, iPad or iPod. EventKit and Core Data are both supported data sources. This enables you to switch between iCal and your custom calendar. Some more information below.

* **EventKit**: All events including the events in your native calendar will be shown. Events added will also be added to your native iCal.
* **CoreData**: Uses Core Data to store your calendar-events. Only events added by your application will be shown. Added events will not be added to iCal. This also allows you to add more details to your events. 

> <img src="http://f.cl.ly/items/3h3B2K2O2q3p2Y2J1c2e/screen1.png" height="230" style="margin-right:20px;" />


Accessing the Calendar Module
--------------------------

To access this module from JavaScript, you would do the following:

>     Titanium.Calendar = Ti.Calendar = require("ag.calendar");

Functions
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

### Example
>     var calendarView = Ti.Calendar.createView({});

## `Ti.Calendar.addEvent(object)`
This will add an event to your calendar object.
### Parameters
* **EventKit**   

 * [string] **title**: Event title
 * [string] **location**: Events location.
 * [string] **note**: Event notes.
 * [date] **startDate**: Events start. (Javascript date object)
 * [date] **endDate**: Events end. (Javascript date object) 
* **Core Data** (Including the above)      

 * [string] **type**: Event type. E.g: *public* or *private*
 * [string] **attendees**: Comma-separated list of attendees
 * [string] **identifier**: Event identifier.
 * [string] **organizer**: Name of the organizer

### Example
>     var endDate = new Date();
	endDate.setHours(endDate.getHours()+3); // Set event to last 3 hours.

>     calendar.addEvent({
        title: "Attend the 2011 WWDC conference",   
        startDate: new Date(),  
        endDate: endDate,   
        location: "San Francisco",   
        identifier: Ti.Calendar.identifier,
        type:"public",
        attendees: "Steve, Phil",
        organizer: "Chris Magnussen",
        note: "Be mad about not getting the iPhone 5"  
    });

## `calendarView.selectTodaysDate([void])`
Select todays date in the calendarView.     
Nothing more, nothing less..

### Example

>     var calendarView = Ti.Calendar.createView();
>     var todayButton = Ti.UI.createButton({title: "Today"});

>     todayButton.addEventListener("click", function() {
        Ti.Calendar.selectTodaysDate();
    });

>     window.setLeftNavButton(todayButton);

Properties
--------
## `Ti.Calendar.identifier (read-only)`

This can be used for the ***identifier***-parameter in the *createView()*-instance. 

### Returns
* [string] MD5 sum of globallyUniqueString

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

(\*) Only available when using Core Data as the data source.   
(\**) When using Core Data your custom identifier is returned, else the auto generated eventIdentifier in EventKit is returned.

### Example
>     calendarView.addEventListener("event:clicked", function(e) {
        var event = e.event;
        var start_date = new Date(event.startDate);
        alert(event.title+" will start "+start_date);
    });


## Usage

Check out the example [app.js](AGCalendar/example/app.js).

## Author

Chris Magnussen for Appgutta, DA.

 * [Twitter][]
 * [Appgutta.no][]

## License

Copyright(c) 2011 by Appgutta, DA. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.


[Twitter]: http://twitter.com/crmag
[Appgutta.no]: http://www.appgutta.no
