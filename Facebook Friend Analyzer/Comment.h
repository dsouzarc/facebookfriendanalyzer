//
//  Comment.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property(strong, nonatomic) NSString *commentID;
@property(strong, nonatomic) NSString *message;
@property(strong, nonatomic) NSString *personID;
@property(strong, nonatomic) NSString *postID;

- (instancetype)initWithCommentID:(NSString*)commentID message:(NSString*)message personID:(NSString*)personID postID:(NSString*)postID;

@end
