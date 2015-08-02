//
//  MainAnimationTransition.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/1/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MainAnimationTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic) BOOL presentViewController;

@end
