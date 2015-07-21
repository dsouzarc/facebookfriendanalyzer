//
//  DatabaseManager.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager ()

@property sqlite3 *database;
@property (strong, nonatomic) NSString *databasePath;

@end

@implementation DatabaseManager


/****************************************
 *       Constructor
 ****************************************/

# pragma mark - Constructor

+ (id) databaseManager
{
    static DatabaseManager *databaseManager = nil;
    
    @synchronized(self) {
        if(databaseManager == nil) {
            databaseManager = [[DatabaseManager alloc] init];
        }
    }
    return databaseManager;
}

- (instancetype) init
{
    self = [super init];
    
    if(self) {
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"facebook.db"]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: self.databasePath]) {
            
            const char *dbpath = [self.databasePath UTF8String];
            if (sqlite3_open(dbpath, &_database) == SQLITE_OK) {
                NSLog(@"Database created");
            }
            else {
                NSLog(@"Failed to open/create database");
            }
        }
        else {
            NSLog(@"Problem creating DB");
        }
        
        [self createPersonTable];
        [self createPostTable];
        [self createLikeTable];
        [self createCommentTable];
    }
    
    return self;
}


/****************************************
 *       People
 ****************************************/

# pragma mark - People

- (void) createPersonTable
{
    NSString *createPostSQL = @"create table if not exists Person(personID integer primary key, name text, profilePicture text)";
    [self createTable:createPostSQL tableName:@"Person"];
}

- (void) addPersonToTable:(Person*)person
{
    //Because ID can be null at times
    NSString *personID = person.id;
    if(!personID) {
        personID = [NSString stringWithFormat:@"%ld", person.name.hash];
    }
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Person(personID, name, profilePicture) values ('%lld', '%@', '%@')", [person.id longLongValue], person.name, person.profilePicture];
    if(![self executeStatement:insertSQL]) {
        NSLog(@"PROBLEM INSERTING PERSON: %@\t%@", person.id, person.name);
    }
    
}

- (void) addPeopleToDatabase:(NSArray*)people
{
    char *errorMessage;
    sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Person *person in people) {
        [self addPersonToTable:person];
    }
    sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
}


/****************************************
 *       Likes
 ****************************************/

# pragma mark - Likes

- (void) createLikeTable
{
    NSString *createPostSQL = @"create table if not exists Like(personWhoLikedItID integer primary key, postID text)";
    [self createTable:createPostSQL tableName:@"Like"];
}

- (void) addLikeToTable:(Like*)like
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Like(personWhoLikedItID, postID) values ('%@', '%@')", like.personWhoLikedItID, like.postID];
    if(![self executeStatement:insertSQL]) {
        NSLog(@"PROBLEM INSERTING LIKE: %@\t%@", like.personWhoLikedItID, like.postID);
    }
}

- (void) addLikesToTable:(NSArray *)likes
{
    char *errorMessage;
    sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Like *like in likes) {
        [self addLikeToTable:like];
    }
    sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
}


/****************************************
 *       Comments
 ****************************************/

# pragma mark - Comments

- (void) createCommentTable
{
    NSString *createPostSQL = @"create table if not exists Comment(commentID integer primary key, message text, personID text, postID text, commentTime text)";
    [self createTable:createPostSQL tableName:@"Comment"];
}

- (void)addCommentToTable:(Comment*)comment
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Comment(commentID, message, personID, postID, commentTime) values ('%lld', '%@', '%@', '%@', '%@')", [comment.commentID longLongValue], comment.message, comment.personID, comment.postID, comment.commentTime];
    if(![self executeStatement:insertSQL]) {
        NSLog(@"PROBLEM INSERTING COMMENT: %@\t%@", comment.commentID, comment.message);
    }
}

- (void) addCommentsToTable:(NSArray *)comments
{
    char *errorMessage;
    sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Comment *comment in comments) {
        [self addCommentToTable:comment];
    }
    sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
}


/****************************************
 *       Posts
 ****************************************/

# pragma mark - Posts

- (void) createPostTable
{
    NSString *createPostSQL = @"create table if not exists Post(postID integer primary key, message text, time text)";
    [self createTable:createPostSQL tableName:@"Post"];
}

- (void)addPostToTable:(Post*)post
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Post(postID, message, time) values ('%lld', '%@', '%@')", [post.postID longLongValue], post.message, post.time];
    if(![self executeStatement:insertSQL]) {
        NSLog(@"PROBLEM INSERTING POST: %@\t%@", post.postID, post.message);
    }
}

- (void) addPostsToTable:(NSArray *)posts
{
    char *errorMessage;
    sqlite3_exec(self.database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Post *post in posts) {
        [self addPostToTable:post];
    }
    sqlite3_exec(self.database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
}


/****************************************
 *       Auxillary Methods
 ****************************************/

# pragma mark - AuxillaryMethods

- (BOOL) executeStatement:(NSString*)sqlQuery
{
    sqlite3_stmt *statement;
    
    sqlite3_prepare_v2(_database, [sqlQuery UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        return false;
    }
    return true;
}

- (void) createTable:(NSString*)createTableStatement tableName:(NSString*)tableName;
{
    const char *sqlStatement = [createTableStatement UTF8String];
    
    char *errorMessage;
    if(sqlite3_exec(_database, sqlStatement, NULL, NULL, &errorMessage) != SQLITE_OK) {
        printf("ERROR CREATING table: %s\t%s\n", [tableName UTF8String], errorMessage);
    }
    else {
        printf("Table created: %s\n", [tableName UTF8String]);
    }
}

@end
