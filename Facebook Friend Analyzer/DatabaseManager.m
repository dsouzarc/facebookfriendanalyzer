//
//  DatabaseManager.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "DatabaseManager.h"

static int MAX_DB_TRIES = 45;
static float DB_SLEEP_FOR_TIME = 1.1;

@interface DatabaseManager ()

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
        sqlite3 *database;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: self.databasePath]) {
            if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
                NSLog(@"Database found and opened");
            }
            else {
                NSLog(@"Failed to open database: %s", sqlite3_errmsg(database));
            }
        }
        else {
            NSError *error;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.databasePath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"Error creating database: %@", error.description);
            }
            else {
                if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
                    NSLog(@"Database created and opened");
                }
                else {
                    NSLog(@"Failed to create and open database");
                }
            }
        }
        
        [self createPersonTable:database];
        [self createPostTable:database];
        [self createLikeTable:database];
        [self createCommentTable:database];
        
        sqlite3_close(database);
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
    
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    
    if(![self executeStatement:deleteAllSQL database:database]) {
        NSLog(@"PROBLEM DELETING ALL PEOPLE");
    }
    
    sqlite3_close(database);
}

- (void) createPersonTable:(sqlite3*)database;
{
    NSString *createPostSQL = @"create table if not exists Person(dbID integer primary key autoincrement, personID text, name text, profilePicture text)";
    [self createTable:createPostSQL tableName:@"Person" database:database];
}

- (void) addPersonToTable:(Person*)person
{
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    [self addPersonToTable:person database:database];
    sqlite3_close(database);
}

- (void) addPersonToTable:(Person *)person database:(sqlite3*)database
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
    if(![self executeStatement:insertSQL database:database]) {
        NSLog(@"PROBLEM INSERTING PERSON: %@\t%@", person.id, person.name);
    }
}

- (void) addPeopleToDatabase:(NSArray*)people
{
    char *errorMessage;
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Person *person in people) {
        [self addPersonToTable:person database:database];
    }
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_close(database);
}

- (NSMutableArray*) getAllPeople
{
    NSMutableArray *allPeople = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    sqlite3_stmt *statement;
    char *allPeopleQuery = "SELECT * FROM Person";
    
    if(sqlite3_prepare_v2(database, allPeopleQuery, -1, &statement, NULL) == SQLITE_OK) {
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
        
        sqlite3_finalize(statement);
    }
    else {
        printf("ERROR GETTING ALL PEOPLE FROM DB: %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
    return allPeople;
}


/****************************************
 *       Likes
 ****************************************/

# pragma mark - Likes

- (void) createLikeTable:(sqlite3*)database
{
    NSString *createPostSQL = @"create table if not exists Like(personWhoLikedItID integer primary key, postID text)";
    [self createTable:createPostSQL tableName:@"Like" database:database];
}

- (void) addLikeToTable:(Like *)like database:(sqlite3*)database
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Like(personWhoLikedItID, postID) values ('%@', '%@')", like.personWhoLikedItID, like.postID];
    if(![self executeStatement:insertSQL database:database]) {
        NSLog(@"PROBLEM INSERTING LIKE: %@\t%@", like.personWhoLikedItID, like.postID);
    }
}

- (void) addLikeToTable:(Like*)like
{
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    [self addLikeToTable:like database:database];
    sqlite3_close(database);
}

- (void) addLikesToTable:(NSArray *)likes
{
    char *errorMessage;
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    for(Like *like in likes) {
        [self addLikeToTable:like database:database];
    }
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_close(database);
}


/****************************************
 *       Comments
 ****************************************/

# pragma mark - Comments

- (void) createCommentTable:(sqlite3*)database
{
    NSString *createPostSQL = @"create table if not exists Comment(commentID integer primary key, message text, personID text, postID text, commentTime text)";
    [self createTable:createPostSQL tableName:@"Comment" database:database];
}

- (void) addCommentToTable:(Comment *)comment database:(sqlite3*)database
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Comment(commentID, message, personID, postID, commentTime) values ('%lld', '%@', '%@', '%@', '%@')", [comment.commentID longLongValue], comment.message, comment.personID, comment.postID, comment.commentTime];
    if(![self executeStatement:insertSQL database:database]) {
        NSLog(@"PROBLEM INSERTING COMMENT: %@\t%@", comment.commentID, comment.message);
    }
}

- (void)addCommentToTable:(Comment*)comment
{
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    [self addCommentToTable:comment database:database];
    sqlite3_close(database);
    
}

- (void) addCommentsToTable:(NSArray *)comments
{
    char *errorMessage;
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    for(Comment *comment in comments) {
        [self addCommentToTable:comment database:database];
    }
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_close(database);
}


/****************************************
 *       Posts
 ****************************************/

# pragma mark - Posts

- (void) createPostTable:(sqlite3*)database
{
    NSString *createPostSQL = @"create table if not exists Post(postID integer primary key, message text, time text)";
    [self createTable:createPostSQL tableName:@"Post" database:database];
}

- (void) addPostToTable:(Post *)post database:(sqlite3*)database
{
    NSString *insertSQL = [NSString stringWithFormat:@"insert into Post(postID, message, time) values ('%lld', '%@', '%@')",
                           [post.postID longLongValue], post.message, post.time];
    if(![self executeStatement:insertSQL database:database]) {
        NSLog(@"PROBLEM INSERTING POST: %@\t%@", post.postID, post.message);
    }
}

- (void)addPostToTable:(Post*)post
{
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    
    [self addPostToTable:post database:database];
    sqlite3_close(database);
}

- (void) addPostsToTable:(NSArray *)posts
{
    char *errorMessage;
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    
    for(Post *post in posts) {
        [self addPostToTable:post database:database];
    }
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_close(database);
}

- (NSMutableArray*) getAllPosts
{
    NSMutableArray *allPosts = [[NSMutableArray alloc] init];
    
    NSString *querySQL = @"SELECT * FROM Post";
    
    sqlite3 *database;
    sqlite3_open([self.databasePath UTF8String], &database);
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare(database, [querySQL UTF8String], -1, &statement, NULL)) {
        while(sqlite3_step(statement) == SQLITE_ROW) {
            NSString *postID = [NSString stringWithFormat:@"%lld", sqlite3_column_int64(statement, 0)];
            NSString *message = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 1)];
            NSString *postDate = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 2)];
            
            Post *post = [[Post alloc] initWithMessage:message postID:postID time:postDate];
            [allPosts addObject:post];
        }
    }
    else {
        NSLog(@"PROBLEM OPENING DB IN GET ALL POSTS");
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return allPosts;
}


/****************************************
 *       Auxillary Methods
 ****************************************/

# pragma mark - AuxillaryMethods

- (BOOL) executeStatement:(NSString*)sqlQuery database:(sqlite3*)database;
{
    sqlite3_stmt *statement;
    
    int errorCount = 0;
    
    //In case the DB is busy on another thread
    while(errorCount < MAX_DB_TRIES) {
        
        //The statement compiled correctly
        if(sqlite3_prepare_v2(database, [sqlQuery UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            //If it wasn't executed correctly
            if (sqlite3_step(statement) != SQLITE_DONE) {
                
                //Keep on trying
                errorCount++;
                printf("ERROR EXECUTING: %s\t%s\n", [sqlQuery UTF8String], sqlite3_errmsg(database));
            }
            
            //Statement successfully executed
            else {
                errorCount = MAX_DB_TRIES;
            }
            
            //Clear up memory
            sqlite3_finalize(statement);
        }
        
        //Problem compiling statement
        else {
            
            //Try again and clear up memory
            errorCount++;
            sqlite3_finalize(statement);
            
            if(errorCount == MAX_DB_TRIES) {
                printf("MAX TRIES REACHED FOR: %s\t%s\n", [sqlQuery UTF8String], sqlite3_errmsg(database));
                return false;
            }
            
            //Pause for some time
            else {
                [NSThread sleepForTimeInterval:DB_SLEEP_FOR_TIME];
            }
        }
    }
    
    return true;
}

- (void) createTable:(NSString*)createTableStatement tableName:(NSString*)tableName database:(sqlite3*)database;
{
    const char *sqlStatement = [createTableStatement UTF8String];
    char *errorMessage;
    if(sqlite3_exec(database, sqlStatement, NULL, NULL, &errorMessage) != SQLITE_OK) {
        printf("ERROR CREATING table: %s\t%s\n", [tableName UTF8String], sqlite3_errmsg(database));
    }
    else {
        printf("Table created: %s\n", [tableName UTF8String]);
    }
}

@end
