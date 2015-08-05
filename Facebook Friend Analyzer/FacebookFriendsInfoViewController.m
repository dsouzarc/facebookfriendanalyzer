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
@property (strong, nonatomic) UIImage *profilePicture;

@property (strong, nonatomic) UIGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesterRecognizer;

@property (strong, nonatomic) IBOutlet UIView *popupView;

@end

@implementation FacebookFriendsInfoViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil profilePicture:(UIImage *)profilePicture person:(Person *)person
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.person = person;
        self.profilePicture = profilePicture;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    self.popupView.layer.cornerRadius = 5;
    self.popupView.layer.shadowOpacity = 0.8;
    self.popupView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    self.nameLabel.text = self.person.name;
    
    self.profilePictureImageView.image = self.profilePicture;
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
    self.profilePictureImageView.layer.masksToBounds = YES;
    
    self.likesImageView.layer.cornerRadius = self.likesImageView.frame.size.width / 4;
    self.likesImageView.layer.masksToBounds = YES;
    
    self.commentsImageView.layer.cornerRadius = self.commentsImageView.frame.size.width / 4;
    self.commentsImageView.layer.masksToBounds = YES;
    
     self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    self.tapGesterRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [self.view addGestureRecognizer:self.tapGesterRecognizer];
}

- (void) tapReceived:(UITapGestureRecognizer*)tapGestureRecognizer
{
    [self removeAnimate];
}

- (void) didSwipe:(UISwipeGestureRecognizer*)swipe
{
    if(swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        [self removeAnimate];
    }
    else {
        NSLog(@"Other gesture detected");
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