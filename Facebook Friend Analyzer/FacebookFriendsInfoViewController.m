//
//  FacebookFriendsInfoViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/4/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "FacebookFriendsInfoViewController.h"

@interface FacebookFriendsInfoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *likesImageView;
@property (strong, nonatomic) IBOutlet UIImageView *commentsImageView;

@property (strong, nonatomic) Person *person;

@end

@implementation FacebookFriendsInfoViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil profilePicture:(UIImage *)profilePicture person:(Person *)person
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.profilePictureImageView.image = profilePicture;
        self.person = person;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = self.person.name;
    
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.image.size.width / 2;
    self.likesImageView.layer.cornerRadius = self.likesImageView.image.size.width / 2;
    self.commentsImageView.layer.cornerRadius = self.commentsImageView.image.size.width / 2;
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [self.view addGestureRecognizer:swipeRecognizer];
}

- (void) didSwipe:(UISwipeGestureRecognizer*)swipe
{
    if(swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        [self removeAnimate];
    }
}

- (void) showAnimate
{
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void) removeAnimate
{
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL completed) {
                         if(completed) {
                             [self.view removeFromSuperview];
                         }
                     }
     ];
}

- (void) showInView:(UIView*)view
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [view addSubview:self.view];
        
        [self showAnimate];
    });
}

@end