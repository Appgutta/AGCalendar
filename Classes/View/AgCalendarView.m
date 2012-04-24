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
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Send event details back to Titanium
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
            EKEvent *event = [dataSource eventAtIndexPath:indexPath];
            eventDetails = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    event.title, @"title", 
                                    event.location, @"location",
                                    event.startDate, @"startDate", 
                                    event.endDate, @"endDate",
                                    event.notes, @"notes",
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

-(void)showPreviousMonth{}
-(void)showFollowingMonth{}
-(void)didSelectDate:(KalDate *)date{}

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

-(void)dealloc
{
    [calendar release];
    [dataSource release];
    [super dealloc];
}

@end