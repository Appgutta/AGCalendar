/* 
 * Created by Chris Magnussen on 04.10.11.
 * Copyright 2011 Appgutta DA. All rights reserved.
 */

#import "Event.h"

@implementation Event

@synthesize startDate, name, attendees, location, endDate, note, identifier, type, organizer;

+ (Event*)eventNamed:(NSString *)aName startDate:(NSDate *)aStartDate endDate:(NSDate *)aEndDate location:(NSString *)aLocation attendees:(NSString *)aAttendees note:(NSString *)aNote identifier:(NSString *)aIdentifier type:(NSString *)aType organizer:(NSString *)aOrganizer;
{
    return [[Event alloc] initWithName:aName startDate:aStartDate endDate:aEndDate location:aLocation attendees:aAttendees note:aNote identifier:aIdentifier type:aType organizer:aOrganizer];
}

- (id)initWithName:(NSString *)aName startDate:(NSDate *)aStartDate endDate:(NSDate *)aEndDate location:(NSString *)aLocation attendees:(NSString *)aAttendees note:(NSString *)aNote identifier:(NSString *)aIdentifier type:(NSString *)aType organizer:(NSString *)aOrganizer
{
  if ((self = [super init])) {
      startDate = aStartDate;
      name = [aName copy];
      attendees = [aAttendees copy];
      location = [aLocation copy];
      endDate = [aEndDate copy];
      note = [aNote copy];
      type = [aType copy];
      identifier = [aIdentifier copy];
      organizer = [aOrganizer copy];
  }
  return self;
}

- (NSComparisonResult)compare:(Event *)otherEvent
{
  NSComparisonResult comparison = [self.startDate compare:otherEvent.startDate];
  if (comparison == NSOrderedSame)
    return [self.name compare:otherEvent.name];
  else
    return comparison;
}


@end
