//
//  FacebookFriendsInfoViewController.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/4/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface FacebookFriendsInfoViewController : UIViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil profilePicture:(UIImage*)profilePicture person:(Person*)person;

@end
