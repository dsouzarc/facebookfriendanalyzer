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

@end

@implementation MainFriendAnalyzerViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.facebookFriendsVC = [[GetFacebookFriendsViewController alloc] initWithNibName:@"GetFacebookFriendsViewController" bundle:[NSBundle mainBundle]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)getFacebookFriends:(id)sender {
    MainAnimationTransition *mainVC = [[MainAnimationTransition alloc] init];
    mainVC.isPresenting = YES;
    self.facebookFriendsVC.modalPresentationStyle = UIModalPresentationCustom;
    self.facebookFriendsVC.transitioningDelegate = mainVC;
    [self presentViewController:self.facebookFriendsVC animated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSLog(@"Call me");
    if (operation == UINavigationControllerOperationPop) {
        return [MainAnimationTransition new];
    }
    return nil;
}


- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    NSLog(@"Here");
    MainAnimationTransition *mainTransition = [MainAnimationTransition new];
    mainTransition.isPresenting = YES;
    return mainTransition;
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed
{
    
    NSLog(@"Here");
    MainAnimationTransition *mainTransition = [MainAnimationTransition new];
    return mainTransition;
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