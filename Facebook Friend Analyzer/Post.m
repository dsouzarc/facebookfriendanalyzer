//
//  Post.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Post.h"

@implementation Post

- (instancetype) initWithMessage:(NSString *)message postID:(NSString *)postID time:(NSString *)time likes:(NSMutableArray *)likes comments:(NSMutableArray *)comments
{
    self = [super init];
    
    if(self) {
        self.message = message;
        self.postID = postID;
        self.time = time;
        self.likes = likes;
        self.comments = comments;
    }
    return self;
}

@end
