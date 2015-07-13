//
//  Comment.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype) initWithCommentID:(NSString *)commentID message:(NSString *)message personID:(NSString *)personID postID:(NSString *)postID
{
    self = [super init];
    
    if(self) {
        self.commentID = commentID;
        self.message = message;
        self.personID = personID;
        self.postID = postID;
    }
    
    return self;
}

@end
