//
//  Globals.h
//  AgCalendar
//
//  Created by Chris Magnussen on 03.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject 
{
    NSString *dbSource;
}

@property (nonatomic,readwrite,retain) NSString *dbSource;

-(void) clearData;
+ (Globals*)sharedDataManager;

@end