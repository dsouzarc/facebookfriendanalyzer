//
//  DatabaseManager.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "Person.h"
#import "Post.h"
#import "Like.h"
#import "Comment.h"

@interface DatabaseManager : NSObject

+ (id)databaseManager;

-(void) addPersonToTable:(Person*)person;
- (void) addPeopleToDatabase:(NSArray*)people;

-(void) addLikeToTable:(Like*)like;

-(void)addCommentToTable:(Comment*)comment;

-(void)addPostToTable:(Post*)post;

@end
