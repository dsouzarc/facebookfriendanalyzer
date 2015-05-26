//
//  LoginViewController.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 5/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FBSDKLoginButton class];
    
    self.loginButton.readPermissions = [self getFacebookPermissions];
    
    if([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"We have access token");
    }
    else {
        NSLog(@"No access token");
    }
}

- (NSArray*) getFacebookPermissions
{
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    
    [permissions addObject:@"public_profile"];
    [permissions addObject:@"user_friends"];
    [permissions addObject:@"user_photos"];
    [permissions addObject:@"user_videos"];
    [permissions addObject:@"user_posts"];
    [permissions addObject:@"user_status"];
    [permissions addObject:@"user_tagged_places"];
    [permissions addObject:@"read_mailbox"];
    [permissions addObject:@"read_stream"];
    
    return permissions;
}

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error) {
        NSLog(@"Successful login");
    }
    else {
        NSLog(@"Problem logging in");
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"Logged out :(");
}

@end
