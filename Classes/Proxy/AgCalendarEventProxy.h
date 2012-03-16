//
//  AgCalendarEventProxy.h
//  AgCalendar
//
//  Created by Chris Magnussen on 02.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "TiProxy.h"
#import <EventKit/EventKit.h>

@interface AgCalendarEventProxy : TiProxy {
@private
}

-(id)initWithEvent:(EKEvent *)event;
-(NSDictionary *)saveEvent:(id)obj;
-(NSDictionary *)deleteEvent:(id)obj;


// setters and getters
-(id)title;
-(void)setTitle:(id)value;
-(id)startDate;
-(void)setStartDate:(id)value;
-(id)endDate;
-(void)setEndDate:(id)value;

@end
