//
//  Globals.m
//  AgCalendar
//
//  Created by Chris Magnussen on 03.10.11.
//  Copyright 2011 Appgutta DA. All rights reserved.
//

#import "Globals.h"

@implementation Globals

static Globals *sharedGlobalDataManager = nil;

@synthesize dbSource;
@synthesize theme;
@synthesize viewEditable = _viewEditable;

+ (Globals*)sharedDataManager
{
    @synchronized(self) {
        if (sharedGlobalDataManager == nil) {
            [[self alloc] init];
        }
    }
    return sharedGlobalDataManager;
}

-(id) init {
	if (self=[super init]) {
        theme = @"default";
        dbSource = @"";
        _viewEditable = NO;
    }
	return self;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedGlobalDataManager == nil) {
        	sharedGlobalDataManager = [super allocWithZone:zone];
            
        	return sharedGlobalDataManager; 
        }
    }
    return nil;
}


-(void) clearData {
    theme = @"default";
	dbSource = @"";
    _viewEditable = NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

@end
