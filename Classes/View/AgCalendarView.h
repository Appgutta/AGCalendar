//
//  AgCalView.h
//  agcal
//
//  Created by Chris Magnussen on 01.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "TiUIView.h"
#import "Kal.h"
#import <EventKit/EventKit.h>
#import "Globals.h"
#import <sqlite3.h>

@class Event;

@interface AgCalendarView : TiUIView <KalViewDelegate, UITableViewDelegate>
{
    Globals *g;
    id dataSource;
@private
    KalViewController *calendar;
}

@property (nonatomic,retain) Globals *g;
//- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath;
//- (id)initWithEvent:(Event *)eventt;

@end
