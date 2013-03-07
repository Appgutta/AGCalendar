//
//  AgCalendarModule.m
//  AgCalendar
//
//  Created by Chris Magnussen on 01.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//
#import "AgCalendarModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "SQLDataSource.h"
#import "EventKitDataSource.h"
#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AgCalendarModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"261E4925-4BE0-4E88-801D-3D34FBE8FD7A";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ag.calendar";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs
-(void)addEvent:(id)event
{
    ENSURE_UI_THREAD_1_ARG(event);
    ENSURE_SINGLE_ARG(event,NSDictionary);
    NSDate *startDate = [event objectForKey:@"startDate"];
    NSDate *endDate = [event objectForKey:@"endDate"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *fromDate = [dateFormat stringFromDate:startDate];
    NSString *toDate = [dateFormat stringFromDate:endDate];
    
    NSDictionary *ev;
    NSDictionary *alarm;
    
    ev = ([event objectForKey:@"recurrence"] != nil) ? [event objectForKey:@"recurrence"] : nil;
    alarm = ([event objectForKey:@"alarm"] != nil) ? [event objectForKey:@"alarm"] : nil;

    
    global = [Globals sharedDataManager];
    dataStore = [global.dbSource isEqualToString:@"coredata"] ? [[SQLDataSource alloc] init] : [[EventKitDataSource alloc] init];
    if ([global.dbSource isEqualToString:@"coredata"]) {
        [dataStore addEvent:[event objectForKey:@"title"] 
                  startDate:fromDate
                    endDate:toDate
                   location:[event objectForKey:@"location"]
                  attendees:[event objectForKey:@"attendees"]
                       note:[event objectForKey:@"note"]
                 identifier:[event objectForKey:@"identifier"]
                       type:[event objectForKey:@"type"]
                  organizer:[event objectForKey:@"organizer"]];
    } else {
        [dataStore addEvent:[event objectForKey:@"title"] 
                  startDate:startDate
                    endDate:endDate
                   location:[event objectForKey:@"location"]
                      notes:[event objectForKey:@"note"]
                 recurrence:ev
                      alarm:alarm];
    }
    
}

-(id)fetchEvents:(id)args
{
    if (args != nil) {
        ENSURE_SINGLE_ARG(args,NSDictionary);
    }
    
    NSDate *fromDate = ([args objectForKey:@"fromDate"] != nil) ? [args objectForKey:@"fromDate"] : [NSDate distantPast];
    NSDate *toDate = ([args objectForKey:@"toDate"] != nil) ? [args objectForKey:@"toDate"] : [NSDate distantFuture];
    
    global = [Globals sharedDataManager];
    dataStore = [global.dbSource isEqualToString:@"coredata"] ? [[SQLDataSource alloc] init] : [[EventKitDataSource alloc] init];
    
    return [dataStore getEvents:fromDate to:toDate];
    
}

-(id)fetchEvent:(id)identifier
{
    global = [Globals sharedDataManager];
    dataStore = [global.dbSource isEqualToString:@"coredata"] ? [[SQLDataSource alloc] init] : [[EventKitDataSource alloc] init];
    return [dataStore getEvent:[identifier objectAtIndex:0]];
    
}

-(BOOL)deleteEvent:(id)identifier
{
    global = [Globals sharedDataManager];
    dataStore = [global.dbSource isEqualToString:@"coredata"] ? [[SQLDataSource alloc] init] : [[EventKitDataSource alloc] init];
    return [dataStore removeEvent:[identifier objectAtIndex:0]];
    
}

-(void)deleteAllEvents:(id)event
{
    ENSURE_UI_THREAD_1_ARG(event);
    
    global = [Globals sharedDataManager];
    if ([global.dbSource isEqualToString:@"coredata"]) {
        dataStore = [[SQLDataSource alloc] init];
        [dataStore deleteAllEvents];
    }
    
}

-(id)identifier
{
    NSString *GUID = [[NSProcessInfo processInfo] globallyUniqueString];
    return [GUID MD5];
}

-(void)theme:(id)source
{
    global = [Globals sharedDataManager];
    global.theme = [source objectAtIndex:0];
}


-(void)dataSource:(id)source
{
    global = [Globals sharedDataManager];
    if ([[source objectAtIndex:0] isEqualToString:@"coredata"]) {
        global.dbSource = @"coredata";
    } else {
        global.dbSource = @"eventkit";
    }
}

-(id)ds
{
    global = [Globals sharedDataManager];
    return global.dbSource;
}

-(id)hasCalendarAccess
{
    global = [Globals sharedDataManager];
    if ([global.dbSource isEqualToString:@"eventkit"]) {
        EKAuthorizationStatus calendarAccess = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if (calendarAccess == EKAuthorizationStatusDenied ||
            calendarAccess == EKAuthorizationStatusNotDetermined ||
            calendarAccess == EKAuthorizationStatusRestricted)
        {
            return [NSNumber numberWithBool:NO];
        } else {
            return [NSNumber numberWithBool:YES];
        }
    }

    return [NSNumber numberWithBool:YES];
}

-(NSString*)dataSource
{
    return global.dbSource;
}

@end
