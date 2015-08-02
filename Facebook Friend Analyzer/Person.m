//
//  Person.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype) initWithID:(NSString *)id name:(NSString *)name profilePicture:(NSString *)profilePicture
{
    self = [super init];
    
    if(self) {
        self.id = id;
        self.name = name;
        self.profilePicture = profilePicture;
    }
    return self;
}

@end