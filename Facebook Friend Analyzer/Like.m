//
//  Like.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Like.h"

@implementation Like

- (instancetype) initWithPersonWhoLikedItID:(NSString *)personWhoLikedItID postID:(NSString *)postID
{
    self = [super init];
    
    if(self) {
        self.personWhoLikedItID = personWhoLikedItID;
        self.postID = postID;
    }
    
    return self;
}

@end
