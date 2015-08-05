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
    // Do any additional setup after loading the view from its nib.
}


@end