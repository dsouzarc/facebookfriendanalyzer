//
//  GetFacebookFriendsViewController.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ViewController.h"

#import "FacebookFriendsInfoViewController.h"

#import "DatabaseManager.h"
#import "Person.h"

#import "PQFBouncingBalls.h"

@interface GetFacebookFriendsViewController : ViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@end
