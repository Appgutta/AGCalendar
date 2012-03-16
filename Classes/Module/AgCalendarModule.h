/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"

@class Event;
@class Globals;

@interface AgCalendarModule : TiModule 
{
    Event *dataStore;
    Globals *global;
}

@end
