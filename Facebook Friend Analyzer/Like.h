//
//  Like.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Like : NSObject

@property(strong, nonatomic) NSString *personWhoLikedItID;
@property(strong, nonatomic) NSString *postID;

- (instancetype) initWithPersonWhoLikedItID:(NSString*)personWhoLikedItID postID:(NSString*)postID;

@end
