//
//  AgCalendarView.h
//  AgCalendar
//
//  Created by Chris Magnussen on 01.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//
#import "TiModule.h"
#import <EventKit/EventKit.h>

@class Event;
@class Globals;

@interface AgCalendarModule : TiModule 
{
    id dataStore;
    id theme;
    Globals *global;
}

@end
