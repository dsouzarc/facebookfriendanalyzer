//
//  Post.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *linkToPhoto;
@property NSInteger numberOfLikes;
@property NSInteger numberOfComments;

- (instancetype) initWithMessage:(NSString*)message postID:(NSString*)postID time:(NSString*)time;
- (instancetype) initWithMessage:(NSString*)message postID:(NSString*)postID time:(NSString*)time linkToPhoto:(NSString*)linkToPhoto;
- (instancetype) initWithDictionary:(NSDictionary*)dictionary;

@end
