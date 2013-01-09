/**
 * Calendar Module for Titanium
 * Read the documentation for more information
 */

// Start off by creating an instance of the module.
Titanium.Calendar = Ti.Calendar = require('ag.calendar');

// Set EventKit as our datasource
Ti.Calendar.dataSource("eventkit");

// Create a window to hold our calendar
var window = Ti.UI.createWindow({
	title: "Calendar",
	backgroundColor: "#fff",
	modal:true
});

// Now, create the calendar view and enable swipe-to-delete 
// by using editable: true
var calendarView = Ti.Calendar.createView({
	top:0,
	editable: true,
	color:"white"
});

// Button to hide our calendar
var options = Ti.UI.createButton({title:"Options"});

// Eventlistener
options.addEventListener("click", function() {
	var dialog = Ti.UI.createOptionDialog({
	  	options: ['Set custom date', 'Delete all events', 'Cancel'],
	  	title: 'Calendar options',
		cancel: 2
	});
	
	dialog.addEventListener("click", function(e) {
		if (e.index == 0) {
			var d = new Date();
			d.setDate(d.getDate()+3);
			calendarView.selectDate(d);
		} else if(e.index == 1) {
			Ti.API.info(Ti.Calendar.ds);
			if (Ti.Calendar.ds == "coredata") {
				Ti.API.info("Deleting all events...");
				Ti.Calendar.deleteAllEvents();
			} else {
				alert("This function is only available while using CoreData as your datasource.");
				return;
			}
		}
	});
	
	dialog.show();
});

var monthNames = [ "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December" ];

// Button to select todays date
var todayButton = Ti.UI.createButton({title:"Today"});

// Eventlistener
todayButton.addEventListener("click", function() {
	calendarView.selectTodaysDate();
});

calendarView.addEventListener("date:clicked", function(e) {
	var date_clicked = new Date(e.event.date);
	Ti.API.info("Date clicked: "+monthNames[date_clicked.getMonth()]+" "+date_clicked.getDate()+".");
});

calendarView.addEventListener("date:longpress", function(e) {
	var date_clicked = new Date(e.event.date);
	var dialog = Ti.UI.createAlertDialog({
	    message: "Would you like to add a new event on "+monthNames[date_clicked.getMonth()]+" "+date_clicked.getDate()+". ?",
	    buttonNames: ['Yeah!', 'Cancel'],
		cancel: 1,
	    title: 'New event'
	});
	
	var endDate = date_clicked;
	endDate.setHours(endDate.getHours()+3);
	
	dialog.addEventListener('click', function(e){
		if (e.index == 0) {
			Ti.Calendar.addEvent({
				title: "Added event",
				startDate: date_clicked,
				endDate: endDate,
				location: "At home",
				identifier: Ti.Calendar.identifier
			});
			
			setTimeout(function() {
				calendarView.selectTodaysDate();
			},1000);
		}
	});
	dialog.show();
});

calendarView.addEventListener("month:next", function() {
	Ti.API.info("Moving to next month");
});

calendarView.addEventListener("month:previous", function() {
	Ti.API.info("Moving to previous month");
});

// Now, let's create an eventlistener to get the data we want
// from our calendar. This event will fire when a user touches
// an event in the tableview.
calendarView.addEventListener('event:clicked', function(e) {
	var event = e.event;
	
	// Log event details
	Ti.API.info(JSON.stringify(event));
	
	// Event dates is returned as strings.
	// To convert the string to a Date() object, input
	// the string in a Date([string]) as shown below.
	var toDateObj = new Date(event.startDate);
	
	// Now you can trigger all date functions
	// http://www.w3schools.com/jsref/jsref_obj_date.asp
	// This example utilizes the toUTCString to show date according to universal time
	Ti.API.info("This event will start: "+toDateObj.toUTCString());
});

// ---- EVENTS

// Now we'll create some different events.
// Event 1: An event starting and ending the same day.
// Let's start by creating our date object.
var endDate = new Date();
endDate.setHours(endDate.getHours()+3);

// Add event to our calendar.
Ti.Calendar.addEvent({
	title: "Starting and ending today",
	startDate: new Date(),
	endDate: endDate,
	location: "At home",
	note: "A note",
	alarm: {
		offset: -900
	},
	// CoreData only
	// Read the docs
	identifier: Ti.Calendar.identifier,
	type:"private",
	attendees: "Bill Gates, Mark Zuckerberg",
	organizer: "Chris"
});

// Event 2: An event recurring every month for one year.
// First, create a recurring end-date.
var recurringEnd = new Date();
recurringEnd.setFullYear(recurringEnd.getFullYear()+1);

// We are gonna use a different way of adding our event 
// to the calendar this time. The first method will work just
// fine, but you may want to build your events using input from
// your users. I'll show you how
var recurringEvent = {};
recurringEvent.title = "Every month for one year";
recurringEvent.startDate = new Date();
recurringEvent.endDate = endDate;
recurringEvent.location = "At home";
recurringEvent.note = "A note";
// EventKit only
recurringEvent.recurrence = { frequency: "month", interval: 1, end: recurringEnd };
recurringEvent.alarm = { offset: -900 };

// CoreData only
recurringEvent.identifier = Ti.Calendar.identifier;
recurringEvent.type = "private";
recurringEvent.attendees = "Bill Gates, Mark Zuckerberg";
recurringEvent.organizer = "Chris";

Ti.Calendar.addEvent(recurringEvent);

// Just to illustrate the recurring event function, we'll create
// an event recurring every other day for one month using our first method.
var recurringEnd2 = new Date();
recurringEnd2.setMonth(recurringEnd2.getMonth()+1);

// The event
Ti.Calendar.addEvent({
	title: "Every other day for one month",
	startDate: new Date(),
	endDate: endDate,
	location: "At home",
	note: "A note",
	recurrence: { 
		frequency: "day", // day, week, month, year
		interval: 2,
		end: recurringEnd2 
	},
	alarm: {
		offset: -900 // 900 seconds = 15 minutes
	}
});

// Add everything to our window and open it.
window.setLeftNavButton(options);
window.setRightNavButton(todayButton);
window.add(calendarView);
window.open({animated: false});

// There seems to be an issue with the Kal library
// When 3 or more events are added it duplicates itself.
// This fix takes care of it while im figuring out whats wrong.
setTimeout(function() {
	calendarView.selectTodaysDate();
},1000);