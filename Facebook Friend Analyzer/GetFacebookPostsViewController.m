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
        
        [self.autocompletePostsToShow addObject:@"yooo"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.facebookPostsTableView registerClass:[ViewPostDownloaderTableViewCell class] forCellReuseIdentifier:@"FacebookPostTVC"];
    [self.facebookPostsTableView registerNib:[UINib nibWithNibName:@"ViewPostDownloaderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FacebookPostTVC"];
}

- (IBAction)backButton:(id)sender {
    
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewPostDownloaderTableViewCell *postDownloader = [self.facebookPostsTableView dequeueReusableCellWithIdentifier:@"FacebookPostTVC"];
    
    if(!postDownloader) {
        postDownloader = [[ViewPostDownloaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookPostTVC"];
    }
    
    return postDownloader;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autocompletePostsToShow.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}


@end
