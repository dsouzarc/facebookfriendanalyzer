//
//  ChooseAnalyzerViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 5/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ChooseAnalyzerViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ChooseAnalyzerViewController ()

@property (strong, nonatomic) NSMutableSet *people;
@property (strong, nonatomic) NSMutableDictionary *posts;

@property (strong, nonatomic) NSMutableArray *postTracker;

@property (strong, nonatomic) DatabaseManager *dbManager;

@end

@implementation ChooseAnalyzerViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.people = [[NSMutableSet alloc] init];
    self.posts = [[NSMutableDictionary alloc] init];
    //self.dbManager = [[DatabaseManager alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self getFacebookFriends];
    //[self getFacebookPosts];
}


/****************************************
 *       FACEBOOK PHOTOS
 ****************************************/

# pragma mark - PHOTOS

- (void) getFacebookPhotos
{
    [self getFacebookPhotos:@"uploaded"];
    [self getFacebookPhotos:@"tagged"];
}

- (void) getFacebookPhotos:(NSString*)kindOfPhotos
{
    NSString *urlRequest = [NSString stringWithFormat:@"me/photos/%@?limit=700", kindOfPhotos];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER PHOTOS\t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            
            NSArray *photos = formattedResults[@"data"];
            for(NSDictionary *photo in photos) {
                
                Post *post = [[Post alloc] initWithMessage:photo[@"name"] postID:photo[@"id"] time:photo[@"created_time"]];
                
                //Get sub comments
                [self getFacebookCommentsWithFacebookPostOrCommentID:post.postID];
            }
            
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            if(pagingInformation && pagingInformation[@"next"]) {
                [self getFacebookPhotosWithURL:pagingInformation[@"next"]];
            }
        }
    }];
}

- (void) getFacebookPhotosWithURL:(NSString*)photosURL
{
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:photosURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *photos = formattedResults[@"data"];
    for(NSDictionary *photo in photos) {
        Post *post = [[Post alloc] initWithMessage:photo[@"name"] postID:photo[@"id"] time:photo[@"created_time"]];
    }
    
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    if(pagingInformation && pagingInformation[@"next"]) {
        [self getFacebookPhotosWithURL:pagingInformation[@"next"]];
    }
    
    else {
        NSLog(@"Here..?");
    }
}


/****************************************
 *       FACEBOOK COMMENTS
 ****************************************/

# pragma mark - Comments

- (void) getFacebookCommentsWithFacebookPostOrCommentID:(NSString*)postID
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@/comments&limit=150", postID];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER COMMENTS\t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            
            NSArray *comments = formattedResults[@"data"];
            for(NSDictionary *commentDict in comments) {
                
                Comment *comment = [[Comment alloc] initWithResponseDictionary:commentDict postID:postID];
                
                //Get sub comments
                [self getFacebookCommentsWithFacebookPostOrCommentID:comment.commentID];
            }
            
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            if(pagingInformation && pagingInformation[@"next"]) {
                [self getFacebookCommentsWithURL:pagingInformation[@"next"] postID:postID];
            }
        }
    }];
}

- (void) getFacebookCommentsWithURL:(NSString*)nextURL postID:(NSString*)postID
{
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:nextURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *comments = formattedResults[@"data"];
    for(NSDictionary *commentDict in comments) {
        Comment *comment = [[Comment alloc] initWithResponseDictionary:commentDict postID:postID];
    }
    
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    if(pagingInformation && pagingInformation[@"next"]) {
        [self getFacebookCommentsWithURL:pagingInformation[@"next"] postID:postID];
    }
    
    else {
        NSLog(@"Here..?");
    }
}


/****************************************
*       FACEBOOK POSTS
****************************************/

# pragma mark - Posts

- (void) getFacebookPosts
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/feed?include_hidden=true&limit=50";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER POSTS\t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            
            NSArray *postResults = formattedResults[@"data"];
            for(NSDictionary *dict in postResults) {
                //NSLog(@"%@", dict[@"message"]);
            }
            
            NSDictionary *firstPost = postResults[1];
            NSString *postID = firstPost[@"id"];
            NSLog(@"Post ID: %@\t%@", postID, firstPost[@"message"]);
            [self getFacebookCommentsWithFacebookPostOrCommentID:postID];
   
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            //[self recursivelyGetPosts:pagingInformation[@"next"]];
        }
    }];
}

- (void) recursivelyGetPosts:(NSString*)url
{
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    
    NSArray *postResults = formattedResults[@"data"];
    for(NSDictionary *dict in postResults) {
        NSLog(@"%@", dict[@"message"]);
    }
    
    if(pagingInformation && pagingInformation[@"next"]) {
        //[self recursivelyGetPosts:pagingInformation[@"next"]];
    }
    
    else {
        NSLog(@"Here..?");
    }
}


/****************************************
 *       FACEBOOK LIKES
 ****************************************/

# pragma mark - Likes

- (void) getFacebookLikesWithPostID:(NSString*)postID
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@/likes&limit=700", postID];
    NSLog(@"URL: %@", urlRequest);
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER LIKES\t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            NSArray *likeIDs = formattedResults[@"data"];
            
            for(NSDictionary *like in likeIDs) {
                NSLog(@"Liked it: %@\t%@", like[@"name"], like[@"id"]);
            }
            
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            [self recursivelyGetFacebookLikesWithURL:pagingInformation[@"next"]];
        }
    }];
}

- (void) recursivelyGetFacebookLikesWithURL:(NSString*)urlRequest
{
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:urlRequest] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    
    NSArray *likeResults = formattedResults[@"data"];
    for(NSDictionary *dict in likeResults) {
        NSLog(@"Liked it: %@\t%@", dict[@"name"], dict[@"id"]);
    }
    
    if(pagingInformation && pagingInformation[@"next"]) {
        [self recursivelyGetFacebookLikesWithURL:pagingInformation[@"next"]];
    }
    else {
        NSLog(@"No more next for FB URL..?");
    }
}


/****************************************
 *       FACEBOOK FRIENDS
 ****************************************/

# pragma mark - Friends

- (void) getFacebookFriends
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/taggable_friends?fields=name,picture.width(300),limit=500";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER FRIENDS TAGGABLE \t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            NSArray *people = [formattedResults objectForKey:@"data"];
            
            NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            
            [self addPeople:people];
            [self recursivelyAddPeople:pagingInformation[@"next"]];
        }
    }];
}

- (void) recursivelyAddPeople:(NSString*)url
{
    NSLog(@"Still working... %ld", (long)self.people.count);
    NSData *data = [[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *formattedResults = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *people = [formattedResults objectForKey:@"data"];
    [self addPeople:people];
    NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
    
    if(pagingInformation && pagingInformation[@"next"]) {
        [self recursivelyAddPeople:pagingInformation[@"next"]];
    }
    
    else {
        [self.dbManager addPeopleToDatabase:[self.people allObjects]];
        NSLog(@"Here..?");
    }
}

- (void) addPeople:(NSArray*)people
{
    for(NSDictionary *person in people) {
        @try {
            NSString *personID = person[@"id"];
            NSString *name = person[@"name"];
            NSDictionary *personData = person[@"picture"];
            NSString *pictureURL = personData[@"url"];
            
            Person *person = [[Person alloc] initWithID:personID name:name profilePicture:pictureURL];
            
            if([self.people containsObject:name]) {
                NSLog(@"ALREADY CONTAINED: %@", name);
            }
            else {
                [self.people addObject:person];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION ADDING: %@", exception.reason);
        }
    }
}

@end
