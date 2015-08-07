//
//  Post.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Post.h"

@implementation Post

- (instancetype) initWithMessage:(NSString *)message postID:(NSString *)postID time:(NSString *)time
{
    self = [self initWithMessage:message postID:postID time:time linkToPhoto:nil];
    return self;
}

- (instancetype) initWithMessage:(NSString *)message postID:(NSString *)postID time:(NSString *)time linkToPhoto:(NSString *)linkToPhoto
{
    self = [super init];
    
    if(self) {
        self.message = message;
        self.postID = postID;
        self.time = time;
        self.linkToPhoto = linkToPhoto;
    }
    return self;
}

@end
