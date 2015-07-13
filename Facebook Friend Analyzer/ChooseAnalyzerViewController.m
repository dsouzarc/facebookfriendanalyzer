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

@end

@implementation ChooseAnalyzerViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.people = [[NSMutableSet alloc] init];
    self.posts = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self getFacebookFriends];
    [self getFacebookPosts];
}

- (void) getFacebookPosts
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/feed?include_hidden=true";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER POSTS");
            NSLog(error.description);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            
            for(id key in formattedResults) {
                NSLog(@"%@", [formattedResults objectForKey:key]);
            }
        }
    }];

}

- (void) recursivelyGetPosts
{
    
}

- (void) getFacebookFriends
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"/me/taggable_friends?fields=name,picture.width(300),limit=500";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER TAGGABLE");
            NSLog(error.description);
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
        NSLog(@"Here..?");
    }
}

- (void) addPeople:(NSArray*)people
{
    for(NSDictionary *person in people) {
        
        @try {
            NSString *name = person[@"name"];
            
            if([self.people containsObject:name]) {
                NSLog(@"ALREADY CONTAINED: %@", name);
            }
            else {
                [self.people addObject:name];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION ADDING: %@", exception.reason);
        }
    }
}


@end
