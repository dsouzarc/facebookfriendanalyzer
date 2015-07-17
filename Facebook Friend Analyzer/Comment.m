//
//  Comment.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype) initWithCommentID:(NSString *)commentID message:(NSString *)message personID:(NSString *)personID postID:(NSString *)postID commentTime:(NSString *)commentTime
{
    self = [super init];
    
    if(self) {
        self.commentID = commentID;
        self.message = message;
        self.personID = personID;
        self.postID = postID;
        self.commentTime = commentTime;
    }
    
    return self;
}

- (instancetype) initWithResponseDictionary:(NSDictionary *)comment postID:(NSString *)postID
{
    NSDictionary *commenter = comment[@"from"];
    NSString *commenterID = commenter[@"id"];
    //NSString *commenterName = commenter[@"name"];
    
    NSString *commentMessage = comment[@"message"];
    NSString *commentTime = comment[@"created_time"];
    NSString *commentID = comment[@"id"];
    
    self = [self initWithCommentID:commentID message:commentMessage personID:commenterID postID:postID commentTime:commentTime];
    
    return self;
}

@end
