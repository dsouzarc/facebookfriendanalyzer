//
//  GetFacebookPostsViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/27/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "GetFacebookPostsViewController.h"

@interface GetFacebookPostsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *facebookPostsTableView;

@property (strong, nonatomic) NSMutableDictionary *allPosts;
@property (strong, nonatomic) NSMutableArray *autocompletePostsToShow;

@property (strong, nonatomic) DatabaseManager *dbManager;

@end

@implementation GetFacebookPostsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.dbManager = [DatabaseManager databaseManager];
    
        self.autocompletePostsToShow = [self.dbManager getAllPosts];
        
        for(Post *post in self.autocompletePostsToShow) {
            [self.allPosts setObject:post forKey:post.postID];
        }
        
        //[self.autocompletePostsToShow addObject:@"yooo"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.facebookPostsTableView registerClass:[ViewPostDownloaderTableViewCell class] forCellReuseIdentifier:@"FacebookPostTVC"];
    [self.facebookPostsTableView registerNib:[UINib nibWithNibName:@"ViewPostDownloaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FacebookPostTVC"];
    
    [self getFacebookPosts];
}

- (IBAction)backButton:(id)sender {
    
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewPostDownloaderTableViewCell *postCell = [self.facebookPostsTableView dequeueReusableCellWithIdentifier:@"FacebookPostTVC"];
    
    if(!postCell) {
        postCell = [[ViewPostDownloaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookPostTVC"];
    }
    
    Post *post = (Post*)[self.autocompletePostsToShow objectAtIndex:indexPath.row];
    
    postCell.postTextView.text = post.message;
    postCell.dateLabel.text = post.time;
    postCell.dateLabel.adjustsFontSizeToFitWidth = YES;
    
    
    return postCell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Yo");
    return self.autocompletePostsToShow.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

/****************************************
 *       FACEBOOK POSTS
 ****************************************/

# pragma mark - Posts

- (void) getFacebookPosts
{
    //GET LIST OF FRIENDS
    NSString *urlRequest = @"me/feed?fields=full_picture,message,id,story,created_time,object_id&limit=15&include_hidden=true";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:urlRequest parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(error) {
            NSLog(@"ERROR AT USER POSTS\t%@", [error description]);
        }
        
        else {
            NSDictionary *formattedResults = (NSDictionary*) result;
            
            NSArray *postResults = formattedResults[@"data"];
            for(NSDictionary *dict in postResults) {

                Post *post = [[Post alloc] initWithDictionary:dict];
                
                [self.allPosts setObject:post forKey:post.postID];
                [self.autocompletePostsToShow addObject:post];
                
                [self getPostLikesAndComments:post];
                
                //NSLog(@"\n\n%@\n\n", dict);
            }
            
            [self.facebookPostsTableView reloadData];
            
            //NSDictionary *pagingInformation = [formattedResults objectForKey:@"paging"];
            //[self.facebookPostsTableView reloadData];
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
        
        NSString *messageAndStory;
        
        if(dict[@"story"]) {
            messageAndStory = [NSString stringWithFormat:@"Story: %@. Message: %@", dict[@"story"], dict[@"message"]];
        }
        else {
            messageAndStory = [NSString stringWithFormat:@"Message: %@", dict[@"message"]];
        }
        
        Post *post = [[Post alloc] initWithMessage:messageAndStory postID:dict[@"id"] time:dict[@"created_time"]];
        
        [self.allPosts setObject:post forKey:post.postID];
        [self.autocompletePostsToShow addObject:post];
        
        [self getPostLikesAndComments:post];
        //NSLog(@"%@", dict[@"message"]);
    }
    
    [self.facebookPostsTableView reloadData];
    
    if(pagingInformation && pagingInformation[@"next"]) {
        [self recursivelyGetPosts:pagingInformation[@"next"]];
    }
    
    else {
        NSLog(@"Here..?");
    }
}

- (void) getPostLikesAndComments:(Post*)post
{
    //[self getFacebookLikesWithPostID:post.postID];
    //[self getFacebookCommentsWithFacebookPostOrCommentID:post.postID depthLevel:0];
}


@end
