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

+(id) databaseManager
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


-(void) createPersonTable
{
    NSString *createPostSQL = @"create table if not exists Person(personID integer primary key, name text)";
    [self createTable:createPostSQL tableName:@"Person"];
}


-(void) createLikeTable
{
    NSString *createPostSQL = @"create table if not exists Like(personWhoLikedItID integer primary key, postID text)";
    [self createTable:createPostSQL tableName:@"Like"];
}

-(void) createCommentTable
{
    NSString *createPostSQL = @"create table if not exists Comment(commentID integer primary key, message text, personID text, postID text)";
    [self createTable:createPostSQL tableName:@"Comment"];
}

-(void) createPostTable
{
    NSString *createPostSQL = @"create table if not exists Post(postID integer primary key, message text, time text, likes text, comments text)";
    [self createTable:createPostSQL tableName:@"Post"];
}

-(void) createTable:(NSString*)createTableStatement tableName:(NSString*)tableName;
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
