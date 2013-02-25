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
    NSString *theme;
    BOOL _viewEditable;
}

@property (nonatomic,readwrite,strong) NSString *dbSource;
@property (nonatomic,readwrite,strong) NSString *theme;
@property BOOL viewEditable;

-(void) clearData;
+ (Globals*)sharedDataManager;

@end