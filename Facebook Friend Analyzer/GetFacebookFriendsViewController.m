//
//  GetFacebookFriendsViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "GetFacebookFriendsViewController.h"

@interface GetFacebookFriendsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;

@end

@implementation GetFacebookFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backToMainViewController:(id)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


@end
