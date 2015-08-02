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

static DatabaseManager *databaseManager = nil;

/****************************************
 *       Constructor
 ****************************************/

# pragma mark - Constructor

+ (id) databaseManager
{
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
        const char *dbpath = [self.databasePath UTF8String];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: self.databasePath]) {
            if (sqlite3_open(dbpath, &_database) == SQLITE_OK) {
                NSLog(@"Database found and opened");
            }
            else {
                NSLog(@"Failed to open database: %s", sqlite3_errmsg(_database));
            }
        }
        else {
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.databasePath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"Error creating database: %@", error.description);
            }
            else {
                if (sqlite3_open(dbpath, &_database) == SQLITE_OK) {
                    NSLog(@"Database created and opened");
                }
                else {
                    NSLog(@"Failed to create and open database");
                }
            }
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

- (void) deleteAllPeople
{
    NSString *deleteAllSQL = @"DELETE FROM Person";
    
    if(![self executeStatement:deleteAllSQL]) {
        NSLog(@"PROBLEM DELETING ALL PEOPLE");
    }
}

- (void) createPersonTable
{
    NSString *createPostSQL = @"create table if not exists Person(dbID integer primary key autoincrement, personID text, name text, profilePicture text)";
    [self createTable:createPostSQL tableName:@"Person"];
}

- (void) addPersonToTable:(Person*)person
{
    //Because ID can be null at times
    NSString *personID = person.id;
    if(!personID) {
        personID = [NSString stringWithFormat:@"%ld", person.name.hash];
    }
    
    NSString *name = person.name;
    if([name containsString:@"'"]) {
        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Person(personID, name, profilePicture) values ('%@', '%@', '%@')", person.id, name, person.profilePicture];
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

- (NSMutableArray*) getAllPeople
{
    NSMutableArray *allPeople = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    char *allPeopleQuery = "SELECT * FROM Person";
    
    if(sqlite3_prepare_v2(self.database, allPeopleQuery, -1, &statement, NULL) == SQLITE_OK) {
        while(sqlite3_step(statement) == SQLITE_ROW) {
            NSString *personID = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            NSString *name = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)];
            NSString *linkToProfPic = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 3)];
            
            if([name containsString:@"''"]) {
                name = [name stringByReplacingOccurrencesOfString:@"''" withString:@"'"];
            }
            
            Person *person = [[Person alloc] initWithID:personID name:name profilePicture:linkToProfPic];
            [allPeople addObject:person];
        }
    }
    else {
        printf("ERROR GETTING ALL PEOPLE FROM DB: %s\n", sqlite3_errmsg(self.database));
    }
    
    return allPeople;
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
        printf("ERROR EXECUTING: %s\t%s\n", [sqlQuery UTF8String], sqlite3_errmsg(_database));
        return false;
    }
    
    sqlite3_finalize(statement);
    
    return true;
}

- (void) createTable:(NSString*)createTableStatement tableName:(NSString*)tableName;
{
    const char *sqlStatement = [createTableStatement UTF8String];
    
    char *errorMessage;
    if(sqlite3_exec(_database, sqlStatement, NULL, NULL, &errorMessage) != SQLITE_OK) {
        printf("ERROR CREATING table: %s\t%s\n", [tableName UTF8String], sqlite3_errmsg(_database));
    }
    else {
        printf("Table created: %s\n", [tableName UTF8String]);
    }
}

@end
