/* 
 * Created by Chris Magnussen on 04.10.11.
 * Copyright 2011 Appgutta DA. All rights reserved.
 */
@interface Event : NSObject
{
    NSDate *startDate;
    NSDate *endDate;
    NSString *name;
    NSString *location;
    NSString *attendees;
    NSString *note;
    NSString *identifier;
    NSString *type;
    NSString *organizer;
}

@property (nonatomic, retain, readonly) NSDate *startDate;
@property (nonatomic, retain, readonly) NSDate *endDate;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *location;
@property (nonatomic, retain, readonly) NSString *attendees;
@property (nonatomic, retain, readonly) NSString *note;
@property (nonatomic, retain, readonly) NSString *identifier;
@property (nonatomic, retain, readonly) NSString *type;
@property (nonatomic, retain, readonly) NSString *organizer;

+ (Event *)eventNamed:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location attendees:(NSString *)attendees note:(NSString *)note identifier:(NSString *)identifier type:(NSString *)type organizer:(NSString *)organizer;
- (id)initWithName:(NSString *)name startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location attendees:(NSString *)attendees note:(NSString *)note identifier:(NSString *)identifier type:(NSString *)type organizer:(NSString *)organizer;
- (NSComparisonResult)compare:(Event *)otherEvent;

@end
