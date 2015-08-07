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
        self.numberOfLikes = 0;
        self.numberOfComments = 0;
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary*)dictionary
{
    NSString *messageAndStory;
    
    if(dictionary[@"story"] && dictionary[@"message"]) {
        messageAndStory = [NSString stringWithFormat:@"Story: %@. Message: %@", dictionary[@"story"], dictionary[@"message"]];
    }
    else if(dictionary[@"story"]) {
        messageAndStory = [NSString stringWithFormat:@"Story: %@", dictionary[@"story"]];
    }
    else if(dictionary[@"message"]){
        messageAndStory = [NSString stringWithFormat:@"Message: %@", dictionary[@"message"]];
    }
    else {
        messageAndStory = @"No message or story";
    }
    
    self = [self initWithMessage:messageAndStory postID:dictionary[@"object_id"] time:dictionary[@"created_time"] linkToPhoto:dictionary[@"full_picture"]];
    return self;
    
}

@end
