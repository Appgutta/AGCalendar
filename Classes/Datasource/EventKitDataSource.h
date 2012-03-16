/*
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "Kal.h"
#import "Globals.h"
#import <dispatch/dispatch.h>

@class EKEventStore, EKEvent;

@interface EventKitDataSource : NSObject <KalDataSource>
{
    NSMutableArray *items; 
    NSMutableArray *events;
    EKEventStore *eventStore;
    Globals *glob;
    dispatch_queue_t eventStoreQueue;
}

+ (EventKitDataSource *)dataSource;
- (EKEvent *)eventAtIndexPath:(NSIndexPath *)indexPath;
- (void)addEvent:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location notes:(NSString *)notes;
- (BOOL)deleteEvent:(id)args;

@end
