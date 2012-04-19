//
//  AgCalViewProxy.m
//  agcal
//
//  Created by Chris Magnussen on 01.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "AgCalendarViewProxy.h"
#import "TiUtils.h"

@implementation AgCalendarViewProxy

-(void)selectTodaysDate:(id)args
{
    [[self view] performSelectorOnMainThread:@selector(showAndSelectToday:) withObject:args waitUntilDone:NO];
}

-(void)selectDate:(id)args
{
    [[self view] performSelectorOnMainThread:@selector(selectDate:) withObject:args waitUntilDone:NO];
}


@end
