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

@end

@implementation GetFacebookPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.facebookPostsTableView registerClass:[ViewPostDownloaderTableViewCell class] forCellReuseIdentifier:@"FacebookPostTVC"];
}

- (IBAction)backButton:(id)sender {
    
}

@end
