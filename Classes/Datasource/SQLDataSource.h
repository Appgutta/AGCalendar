//
//  CoreDataSource.h
//  AgCalendar
//
//  Created by Chris Magnussen on 04.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import <sqlite3.h>
#import "Kal.h"
#import "Globals.h"

@class Event;

@interface SQLDataSource : NSObject <KalDataSource>
{
    NSMutableArray *items;
    NSMutableArray *events;
    NSString *databasePath;
    NSMutableArray *eventList;
    Globals *glob;
    sqlite3 *db;
}

+ (SQLDataSource *)dataSource;
- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath;
- (void)addEvent:(NSString *)name startDate:(NSString *)startDate endDate:(NSString *)endDate location:(NSString *)location attendees:(NSString *)attendees note:(NSString *)note identifier:(NSString *)identifier type:(NSString *)type organizer:(NSString *)organizer;
- (BOOL)deleteAllEvents;
- (id)getEvents:(NSDate *)fromDate to:(NSDate *)toDate;
- (id)getEvent:(NSString *)identifier;
- (BOOL)removeEvent:(NSString *)identifier;

@end
