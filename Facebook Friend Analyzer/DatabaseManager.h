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

- (void) deleteAllPeople;
- (void) addPersonToTable:(Person*)person;
- (void) addPeopleToDatabase:(NSArray*)people;

- (NSMutableArray*) getAllPeople;

- (void) addLikeToTable:(Like*)like;
- (void) addLikesToTable:(NSArray*)likes;

- (void) addCommentToTable:(Comment*)comment;
- (void) addCommentsToTable:(NSArray*)comments;

- (void) addPostToTable:(Post*)post;
- (void) addPostsToTable:(NSArray*)posts;
- (NSMutableArray*) getAllPosts;

@end
