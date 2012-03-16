/**
 * Calendar Module for Titanium - Advanced example
 *
 * Showing the main functionality of the Calendar.
 */

// Start off by creating an instance of the module.
Titanium.Calendar = Ti.Calendar = require('ag.calendar');

// Datasource - Read documentation
Ti.Calendar.dataSource("eventkit");

// Add an event to the calendar
var endDate = new Date();
endDate.setHours(endDate.getHours()+3);

var calEvent = {};
calEvent.title = "Honor Steve Jobs";
calEvent.startDate = new Date();
calEvent.endDate = endDate;
calEvent.location = "Silicon Valley";
calEvent.note = "Send your condolences!";

// The following will only work when using Core Data as your dataSource.
// Just remove it if you are using EventKit.
calEvent.attendees = "Bill Gates, Mark Zuckerberg";
calEvent.identifier = Ti.Calendar.identifier; // Will generate a globally unique identifier for you. (MD5(GUID))
calEvent.type = "private";
calEvent.organizer = "Chris";

// Save it!
Ti.Calendar.addEvent(calEvent);

// Can also be done like this:
Ti.Calendar.addEvent({
	title: "Honor Steve Jobs",
	startDate: new Date(),
	endDate: endDate,
	location: "Silicon Valley",
	identifier: Ti.Calendar.identifier,
	type:"private",
	attendees: "Bill Gates, Mark Zuckerberg",
	note: "Send your condolences!",
	organizer: "Chris"
});

// Open the first shiny white window
var window = Ti.UI.createWindow({
	title: "Calendar",
	backgroundColor: "#fff",
	modal:true
});

// Our first initiation of the actual Calendar View.
var calendarView = Ti.Calendar.createView({
	top:0,
	color:"red"
});

// Hide the calendar.
var hideButton = Ti.UI.createButton({title:"Hide"});

// Select todays date
var todayButton = Ti.UI.createButton({title:"Today"});

// Eventlistener on the close-button.
// This will close the window containing our calendar.
hideButton.addEventListener("click", function() {
	if (hideButton.title == "Hide") {
		calendarView.animate({opacity:0, duration:400}, function() {
			calendarView.hide();
		});
		hideButton.title = "Show";
	} else {
		calendarView.show();
		calendarView.animate({opacity:1, duration:400}); 
		hideButton.title = "Hide";
	}
});

// Eventlistener on the today-button.
// This will select todays date in the calendar.
todayButton.addEventListener("click", function() {
	calendarView.selectTodaysDate();
});

// Eventlistener on our Calendar.
// This will give you all the data stored in each event.
calendarView.addEventListener('event:clicked', function(e) {
	var event = e.event;
	
	// Use the built in detailsView
	Ti.Calendar.showDetails(event);
	
	// ...or create your own.
	
	// Dates retrieved from our API is strings.
	// If you want to create a Date() object, its as easy
	// as inputing our date-string to the Date() object
	// as shown below.
	var toDateObj = new Date(event.startDate);
	
	// Now you can trigger all date functions
	// http://www.w3schools.com/jsref/jsref_obj_date.asp
	// This example utilizes the toUTCString to show date according to universal time
	alert("This event will start: "+toDateObj.toUTCString());
});

window.setLeftNavButton(hideButton);
window.setRightNavButton(todayButton);
window.add(calendarView);
window.open({animated: false});