/* 
 * Created by Chris Magnussen on 04.10.11.
 * Copyright 2011 Appgutta DA. All rights reserved.
 */

#import "EventKitDataSource.h"
#import <EventKit/EventKit.h>

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
  return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface EventKitDataSource ()
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation EventKitDataSource

+ (EventKitDataSource *)dataSource
{
  return [[[self class] alloc] init];
}

- (id)init
{
  if ((self = [super init])) {
    eventStore = [[EKEventStore alloc] init];
    events = [[NSMutableArray alloc] init];
    items = [[NSMutableArray alloc] init];
    eventStoreQueue = dispatch_queue_create("ag.calendar", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];
  }
  return self;
}

- (void)eventStoreChanged:(NSNotification *)note
{
  [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification object:nil];
}

- (EKEvent *)eventAtIndexPath:(NSIndexPath *)indexPath
{
  return [items objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    glob = [Globals sharedDataManager];
    return glob.viewEditable;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EKEvent *event = [self eventAtIndexPath:indexPath];
        NSError *error = nil;
        [eventStore removeEvent:event span: EKSpanFutureEvents error:&error];
        [items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    /*cell.imageView.contentMode = UIViewContentModeScaleAspectFill;*/
    
    EKEvent *event = [self eventAtIndexPath:indexPath];
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = event.location;
    cell.indentationLevel = 4;
        
        
    if (event.allDay) {
        // Localization
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *startComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.startDate];
        NSDateComponents *endComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.endDate];
        NSInteger hour_start = [startComp hour];
        NSInteger minute_start = [startComp minute];
        NSInteger hour_end = [endComp hour];
        NSInteger minute_end = [endComp minute];
            
        UILabel *time_start, *time_end;
            
        time_start = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 5.0, 35.0, 15.0)];
        time_start.tag = 1;
        time_start.textColor = [UIColor darkGrayColor];
        time_start.textAlignment = UITextAlignmentLeft;
        time_start.font = [UIFont boldSystemFontOfSize:13.0];
        time_start.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        time_start.backgroundColor = [UIColor clearColor];
        time_start.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:time_start];
            
        time_end = [[UILabel alloc] initWithFrame:CGRectMake(27.0, 20.0, 35.0, 25.0)];
        time_end.tag = 2;
        time_end.textColor = [UIColor darkGrayColor];
        time_end.textAlignment = UITextAlignmentLeft;
        time_end.font = [UIFont boldSystemFontOfSize:13.0];
        time_end.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        time_end.backgroundColor = [UIColor clearColor];
        time_end.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:time_end];
            
        time_start.text = [NSString stringWithFormat:@"%02d:%02d", hour_start, minute_start];
        time_end.text = [NSString stringWithFormat:@"%02d:%02d", hour_end, minute_end];
            
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [items count];
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [events removeAllObjects];
    dispatch_async(eventStoreQueue, ^{
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:nil];
        NSArray *matchedEvents = [eventStore eventsMatchingPredicate:predicate];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [events removeAllObjects];
            [events addObjectsFromArray:matchedEvents];
            [delegate loadedDataSource:self];
        });
    });}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
  return [[self eventsFrom:fromDate to:toDate] valueForKeyPath:@"startDate"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
  [items addObjectsFromArray:[self eventsFrom:fromDate to:toDate]];
}

- (void)removeAllItems
{
  [items removeAllObjects];
}

- (BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:requiredVersion options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (void)createEvent:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location notes:(NSString *)notes recurrence:(NSDictionary *)recurrence alarm:(NSDictionary *)alarm
{
    EKEvent *_event = [EKEvent eventWithEventStore:eventStore];
    _event.title = name;
    
    _event.startDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:startDate];
    _event.location = location;
    _event.notes = notes;
    _event.endDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:endDate];
    
    EKAlarm *al = [EKAlarm alarmWithRelativeOffset:[[alarm objectForKey:@"offset"] intValue]];
    _event.alarms = [NSArray arrayWithObject:al];
    
    BOOL isRecurrenceFrequencyExists = TRUE;
    
    EKRecurrenceFrequency recurrenceFrequency;
    if ([[recurrence objectForKey:@"frequency"] isEqualToString: @"day"])
        recurrenceFrequency = EKRecurrenceFrequencyDaily;
    else if([[recurrence objectForKey:@"frequency"] isEqualToString: @"week"])
        recurrenceFrequency = EKRecurrenceFrequencyWeekly;
    else if([[recurrence objectForKey:@"frequency"] isEqualToString: @"month"])
        recurrenceFrequency = EKRecurrenceFrequencyMonthly;
    else if([[recurrence objectForKey:@"frequency"] isEqualToString: @"year"])
        recurrenceFrequency = EKRecurrenceFrequencyYearly;
    else
        isRecurrenceFrequencyExists = FALSE;
    
    if(isRecurrenceFrequencyExists) {
        
        EKRecurrenceEnd *end = [EKRecurrenceEnd recurrenceEndWithEndDate:[[NSDate alloc] initWithTimeInterval:1200 sinceDate:[recurrence objectForKey:@"end"]]];
        
        EKRecurrenceRule *recurrenceRule = [[EKRecurrenceRule alloc]
                                            initRecurrenceWithFrequency:recurrenceFrequency
                                            interval:[[recurrence objectForKey:@"interval"] intValue]
                                            end:end];
        
        [_event addRecurrenceRule:recurrenceRule];
        
    }
    [_event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err = nil;
    [eventStore saveEvent:_event span:EKSpanThisEvent error:&err];

}

-(id)getEvents:(NSDate *)fromDate to:(NSDate *)toDate
{
    eventList = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:nil];
    NSArray *evts = [eventStore eventsMatchingPredicate:predicate];
    
    for (EKEvent *event in evts)
    {
        if (IsDateBetweenInclusive(event.startDate, fromDate, toDate)) {
            NSString *alarmOffset = [NSString stringWithFormat:@"%f", [[event.alarms objectAtIndex:0] relativeOffset]];
            [eventList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  event.title, @"title",
                                  event.location, @"location",
                                  alarmOffset, @"alarmOffset",
                                  event.startDate, @"startDate",
                                  event.endDate, @"endDate",
                                  event.attendees, @"attendees",
                                  event.organizer, @"organizer",
                                  event.recurrenceRules, @"recurrenceRules",
                                  event.eventIdentifier, @"identifier",
                                  nil]];
        }
    }
    
    return eventList;
}

-(id)getEvent:(NSString *)identifier
{
    eventList = [[NSMutableArray alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:identifier];
    
    NSString *alarmOffset = [NSString stringWithFormat:@"%f", [[event.alarms objectAtIndex:0] relativeOffset]];
    [eventList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                         event.title, @"title",
                         event.location, @"location",
                         alarmOffset, @"alarmOffset",
                         event.startDate, @"startDate",
                         event.endDate, @"endDate",
                         event.attendees, @"attendees",
                         event.organizer, @"organizer",
                         event.recurrenceRules, @"recurrenceRules",
                         event.eventIdentifier, @"identifier",
                         nil]];
    
    return eventList;
}

-(BOOL)removeEvent:(NSString *)identifier
{
    EKEvent *event = [eventStore eventWithIdentifier:identifier];
    NSError *error = nil;
    [eventStore removeEvent:event span: EKSpanFutureEvents error:&error];
    
    return (error == nil) ? NO : YES;
    //[items removeObject:event];
}


- (void)addEvent:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location notes:(NSString *)notes recurrence:(NSDictionary *)recurrence alarm:(NSDictionary *)alarm
{
    if([self checkIsDeviceVersionHigherThanRequiredVersion:@"6.0"]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self createEvent:name startDate:startDate endDate:endDate location:location notes:notes recurrence:recurrence alarm:alarm];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar" message:@"You didnt allow access to your calendar." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil, nil];
                [alert show];
            }
        }];
    } else {
        [self createEvent:name startDate:startDate endDate:endDate location:location notes:notes recurrence:recurrence alarm:alarm];
    }
}

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
  NSMutableArray *matches = [NSMutableArray array];
  for (EKEvent *event in events)
    if (IsDateBetweenInclusive(event.startDate, fromDate, toDate))
      [matches addObject:event];
  
  return matches;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    dispatch_sync(eventStoreQueue, ^{
    });
    dispatch_release(eventStoreQueue);
}

@end
