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

@property (strong, nonatomic) NSMutableDictionary *facebookFriends;

@end

@implementation GetFacebookFriendsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.facebookFriends = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = @"Yooo";
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.facebookFriends.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)backToMainViewController:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
