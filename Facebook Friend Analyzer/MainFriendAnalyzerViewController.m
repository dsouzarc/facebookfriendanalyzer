//
//  MainFriendAnalyzerViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/25/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainFriendAnalyzerViewController.h"

@interface MainFriendAnalyzerViewController ()

@property (strong, nonatomic) GetFacebookFriendsViewController *facebookFriendsVC;

@property (strong, nonatomic) MainAnimationTransition *transitioner;

@end

@implementation MainFriendAnalyzerViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.transitioner = [[MainAnimationTransition alloc] init];
        self.facebookFriendsVC = [[GetFacebookFriendsViewController alloc] initWithNibName:@"GetFacebookFriendsViewController" bundle:[NSBundle mainBundle]];
        self.facebookFriendsVC.modalPresentationStyle = UIModalPresentationCustom;
        self.facebookFriendsVC.transitioningDelegate = self.transitioner;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)getFacebookFriends:(id)sender {
    
    self.transitioner.presentViewController = YES;
    [self presentViewController:self.facebookFriendsVC animated:YES completion:nil];
}

- (IBAction)getFacebookPosts:(id)sender {
    
}

- (IBAction)getFacebookPictures:(id)sender {
    
}

- (IBAction)getFacebookVideos:(id)sender {
    
}

- (IBAction)viewResults:(id)sender {
    
}

@end