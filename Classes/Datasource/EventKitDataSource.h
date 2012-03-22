/* 
 * Created by Chris Magnussen on 04.10.11.
 * Copyright 2011 Appgutta DA. All rights reserved.
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
