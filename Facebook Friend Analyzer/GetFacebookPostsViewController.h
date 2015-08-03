//
//  GetFacebookPostsViewController.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/27/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ViewController.h"

#import "ViewPostDownloaderTableViewCell.h"
#import "DatabaseManager.h"
#import "Post.h"
#import "Like.h"

#import "PQFBouncingBalls.h"

@interface GetFacebookPostsViewController : ViewController <UITableViewDelegate, UITableViewDataSource>

@end
