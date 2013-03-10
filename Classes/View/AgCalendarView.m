//
//  AgCalendarView.m
//  AgCalendar
//
//  Created by Chris Magnussen on 01.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "AgCalendarView.h"
#import "TiUtils.h"
#import "Event.h"
#import "SQLDataSource.h"
#import "EventKitDataSource.h"

@implementation AgCalendarView

@synthesize g;

-(KalViewController*)calendar
{
    if (calendar==nil)
    {
        g = [Globals sharedDataManager];
        calendar = [[KalViewController alloc] init];
        dataSource = [g.dbSource isEqualToString:@"coredata"] ? [[SQLDataSource alloc] init] : [[EventKitDataSource alloc] init];
        calendar.dataSource = dataSource;
        calendar.delegate = self;
        [self addSubview:calendar.view];
    }
    return calendar;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.proxy _hasListeners:@"event:clicked"]) {
        NSDictionary *eventDetails;
        if ([g.dbSource isEqualToString:@"coredata"]) {
            Event *event = [dataSource eventAtIndexPath:indexPath];
            eventDetails = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    event.name, @"title", 
                                    event.location, @"location",
                                    event.attendees, @"attendees", 
                                    event.type, @"type",
                                    event.identifier, @"identifier",
                                    event.note, @"note", 
                                    event.startDate, @"startDate", 
                                    event.endDate, @"endDate",
                                    event.organizer, @"organizer",
                            nil];
        } else {
            EKEvent *event = (EKEvent *) [dataSource eventAtIndexPath:indexPath];
            NSString *alarmOffset = [NSString stringWithFormat:@"%f", [[event.alarms objectAtIndex:0] relativeOffset]];
            eventDetails = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    event.title, @"title", 
                                    event.location, @"location",
                                    event.startDate, @"startDate",
                                    event.eventIdentifier, @"identifier",
                                    event.endDate, @"endDate",
                                    event.notes, @"notes",
                                    alarmOffset, @"alarmOffset",
                            nil];
        }
        
        NSDictionary *eventSelected = [NSDictionary dictionaryWithObjectsAndKeys: eventDetails, @"event", nil];
		[self.proxy fireEvent:@"event:clicked" withObject:eventSelected];
	}
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if (calendar!=nil)
    {
        [TiUtils setView:calendar.view positionRect:bounds];
    }
}

-(void)showPreviousMonth
{
    if ([self.proxy _hasListeners:@"month:previous"])
    {
        [self.proxy fireEvent:@"month:previous" withObject:nil];
    }
}

-(void)showFollowingMonth
{
    if ([self.proxy _hasListeners:@"month:next"])
    {
        [self.proxy fireEvent:@"month:next" withObject:nil];
    }
}


// Fires when there's a long press on the date tile.
-(void)didSelectDateLong:(NSDate *)date
{
    if ([self.proxy _hasListeners:@"date:longpress"])
    {
        NSDictionary *returnDate = [NSDictionary dictionaryWithObjectsAndKeys:date, @"date", nil];
        NSDictionary *dateSelected = [NSDictionary dictionaryWithObjectsAndKeys: returnDate, @"event", nil];
        [self.proxy fireEvent:@"date:longpress" withObject:dateSelected];
    }
}

-(void)showPreviousMonth:(id)args
{
    if ([self.proxy _hasListeners:@"month:previous"])
    {
        [self.proxy fireEvent:@"month:previous" withObject:nil];
    }
}

-(void)showFollowingMonth:(id)args
{
    if ([self.proxy _hasListeners:@"month:next"])
    {
        [self.proxy fireEvent:@"month:next" withObject:nil];
    }
}

-(void)didSelectDate:(NSDate *)date
{
    if ([self.proxy _hasListeners:@"date:clicked"])
    {
        NSDictionary *returnDate = [NSDictionary dictionaryWithObjectsAndKeys:date, @"date", nil];
        NSDictionary *dateSelected = [NSDictionary dictionaryWithObjectsAndKeys: returnDate, @"event", nil];
        [self.proxy fireEvent:@"date:clicked" withObject:dateSelected];
    }
}

- (void)showAndSelectToday:(id)args
{
    [[self calendar] showAndSelectDate:[NSDate date]];
}

- (void)selectDate:(id)args
{
    [[self calendar] showAndSelectDate:[args objectAtIndex:0]];
}



-(void)setColor_:(id)color
{
    UIColor *c = [[TiUtils colorValue:color] _color];
    KalViewController *s = [self calendar];
    s.view.backgroundColor = c;
}

-(void)setEditable_:(id)value
{
    g = [Globals sharedDataManager];
    BOOL editable = [TiUtils boolValue:value];
    g.viewEditable = editable;
}


@end