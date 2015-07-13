//
//  DatabaseManager.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager

+(id) databaseManager
{
    static DatabaseManager *databaseManager = nil;
    
    @synchronized(self) {
        if(databaseManager == nil) {
            databaseManager = [[DatabaseManager alloc] init];
        }
    }
    return databaseManager;
}

- (instancetype) init
{
    self = [super init];
    
    if(self) {
        
    }
    return self;
}

@end
