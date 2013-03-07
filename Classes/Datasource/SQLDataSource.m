//
//  CoreDataSource.m
//  AgCalendar
//
//  Created by Chris Magnussen on 04.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "SQLDataSource.h"
#import "Event.h"
#import "TiUtils.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface SQLDataSource ()
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation SQLDataSource

+ (SQLDataSource *)dataSource
{
    return [[[self class] alloc] init];
}

- (NSString *)dbPath:(NSString*)dataBase
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: dataBase]];
	
	return databasePath;
}


- (id)init
{
    if ((self = [super init])) {
        items = [[NSMutableArray alloc] init];
        events = [[NSMutableArray alloc] init];
        
        NSString *docsDir;
        NSArray *dirPaths;
        
        databasePath = [self dbPath:@"events.db"];
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        if ([filemgr fileExistsAtPath: databasePath ] == NO)
        {
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, &db) == SQLITE_OK)
            {
                char *errMsg;
                const char *sql_stmt = "CREATE TABLE IF NOT EXISTS Events (id integer PRIMARY KEY AUTOINCREMENT, title text DEFAULT empty, date_start VARCHAR(25,0), date_end VARCHAR(25,0),note text DEFAULT empty, location text DEFAULT empty, identifier VARCHAR(50,0) DEFAULT empty, type VARCHAR(20,0) DEFAULT empty, attendees text DEFAULT empty, organizer VARCHAR(50,0) DEFAULT empty);";
                                
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create instance");
                }
                
                sqlite3_close(db);
                
            } else {
                NSLog(@"Failed to open/create instance");
            }
        }
        
    }
    return self;
}

- (Event *)eventAtIndexPath:(NSIndexPath *)indexPath
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
        Event *ev = [self eventAtIndexPath:indexPath];
        [self removeEvent:ev.identifier];
        [events removeObjectAtIndex:indexPath.row];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    Event *event = [self eventAtIndexPath:indexPath];
        
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text = event.location;
    cell.indentationLevel = 4;
        
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
        
    
    /*Event *event = [self eventAtIndexPath:indexPath];
    //cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"flags/%@.gif", event.location]];
    cell.textLabel.text = event.name;*/
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (void)loadEventsFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
	if(sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
		const char *sql = "select title, location, type, identifier, note, date_start, date_end, attendees, organizer from Events where date_start between ? and ?";
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            [fmt setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            sqlite3_bind_text(stmt, 1, [[fmt stringFromDate:fromDate] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 2, [[fmt stringFromDate:toDate] UTF8String], -1, SQLITE_STATIC);
            [fmt setDateFormat:@"yyyy-MM-dd HH:mm"];
			while(sqlite3_step(stmt) == SQLITE_ROW) {
                NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
				NSString *location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                NSString *eventType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                NSString *identifier = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
                NSString *note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
                NSString *date_from = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                NSString *date_to = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                NSString *attendees = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
                NSString *organizer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)];
                [events addObject:[Event eventNamed:title startDate:[fmt dateFromString:date_from] endDate:[fmt dateFromString:date_to] location:location attendees:attendees note:note identifier:identifier type:eventType organizer:organizer]];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
    [delegate loadedDataSource:self];
}

-(id)getEvents:(NSDate *)fromDate to:(NSDate *)toDate {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    eventList = [[NSMutableArray alloc] init];
    
	if(sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
		const char *sql = "select title, location, type, identifier, note, date_start, date_end, attendees, organizer from Events where date_start between ? and ?";
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            sqlite3_bind_text(stmt, 1, [[fmt stringFromDate:fromDate] UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(stmt, 2, [[fmt stringFromDate:toDate] UTF8String], -1, SQLITE_STATIC);
            [fmt setDateFormat:@"yyyy-MM-dd HH:mm"];
			while(sqlite3_step(stmt) == SQLITE_ROW) {
                NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
				NSString *location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                NSString *eventType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                NSString *identifier = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
                NSString *note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
                NSString *date_from = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                NSString *date_to = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                NSString *attendees = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
                NSString *organizer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)];
                [eventList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     title, @"title",
                                                     location, @"location",
                                                     eventType, @"type",
                                                     identifier, @"identifier",
                                                     note, @"note",
                                                     date_from, @"startDate",
                                                     date_to, @"endDate",
                                                     attendees, @"attendees",
                                                     organizer, @"organizer",
                                                     nil]];
			}
		}
		sqlite3_finalize(stmt);
	}
	sqlite3_close(db);
    
    return eventList;
}

-(id)getEvent:(NSString *)identifier
{
    eventList = [[NSMutableArray alloc] init];
    
	if(sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
		const char *sql = "select title, location, type, identifier, note, date_start, date_end, attendees, organizer from Events where identifier=?";
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, [identifier UTF8String], -1, SQLITE_STATIC);
			while(sqlite3_step(stmt) == SQLITE_ROW) {
                NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
				NSString *location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                NSString *eventType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                NSString *identifier = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
                NSString *note = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
                NSString *date_from = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                NSString *date_to = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                NSString *attendees = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
                NSString *organizer = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)];
                [eventList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      title, @"title",
                                      location, @"location",
                                      eventType, @"type",
                                      identifier, @"identifier",
                                      note, @"note",
                                      date_from, @"startDate",
                                      date_to, @"endDate",
                                      attendees, @"attendees",
                                      organizer, @"organizer",
                                      nil]];
			}
            sqlite3_finalize(stmt);
		}
        sqlite3_close(db);
    }
    
    return eventList;

}

-(BOOL)checkEvent:(NSString *)identifier
{
    const char *dbpath = [databasePath UTF8String];
    BOOL result = NO;
    sqlite3_stmt    *statement;
 
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT title FROM Events WHERE identifier=\"%@\"", identifier];
 
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = YES;
            } else {
                result = NO;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    
    return result;
}

-(BOOL)removeEvent:(NSString *)identifier
{
    BOOL result = NO;
    if ([self checkEvent:identifier] == YES) {
        sqlite3_stmt *statement;
    
        const char *dbpath = [databasePath UTF8String];
    
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM Events WHERE identifier=\"%@\"", identifier];
        
            const char *query_stmt = [querySQL UTF8String];
        
            if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                sqlite3_exec(db,query_stmt,NULL,NULL,NULL);
                result = YES;
            } else {
                result = NO;
            }
        
            sqlite3_finalize(statement);
            sqlite3_close(db);

        } else {
            result = NO;
        }
    } else {
        NSLog(@"[INFO] No event found with identifier %@", identifier);
    }
    
    return result;
}

-(BOOL)deleteAllEvents
{
    BOOL result;
    sqlite3_stmt *statement;
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        NSLog(@"DELETE FROM Events");
        NSString *querySQL = [NSString stringWithFormat: @"DELETE FROM Events"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_exec(db,query_stmt,NULL,NULL,NULL);
            result = YES;
        } else {
            result = NO;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
        
    } else {
        result = NO;
    }
    
    return result;
}

- (void)addEvent:(NSString *)name startDate:(NSString *)startDate endDate:(NSString *)endDate location:(NSString *)location attendees:(NSString *)attendees note:(NSString *)note identifier:(NSString *)identifier type:(NSString *)type organizer:(NSString *)organizer
{
    
    if ([self checkEvent:identifier] == NO) {
        sqlite3_stmt *statement;
        
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat: @"insert into Events (title, date_start, date_end, location, attendees, note, identifier, type, organizer) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", name, startDate, endDate, location, attendees, note, identifier, type, organizer];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(db, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
            } else {
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    } else {
        NSLog(@"[INFO] An event with the same identifier already exist");
    }
}


- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [events removeAllObjects];
    [self loadEventsFrom:fromDate to:toDate delegate:delegate];
}

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

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSMutableArray *matches = [NSMutableArray array];
    for (Event *event in events)
        if (IsDateBetweenInclusive(event.startDate, fromDate, toDate))
            [matches addObject:event];
    
    return matches;
}


@end
