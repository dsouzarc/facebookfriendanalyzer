//
//  MainAnimationTransition.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/1/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainAnimationTransition.h"

@implementation MainAnimationTransition

- (instancetype) init
{
    self = [super init];
    if(self) {
        self.presentViewController = NO;
    }
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presentViewController = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presentViewController = NO;
    return self;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.presentViewController = NO;
}

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = fromController.view.frame;

    if(self.presentViewController) {
        fromController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromController.view];
        [transitionContext.containerView addSubview:toController.view];
        
        CGRect startFrame = endFrame;
        
        //All the way on the right
        startFrame.origin.x += 370;
        
        toController.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                             toController.view.frame = endFrame;
                             [[transitionContext containerView] addSubview:toController.view];
                         }
                         completion:^(BOOL completed) {
                             [transitionContext completeTransition:YES];
                         }
         ];
    }
    else {
        toController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toController.view];
        [transitionContext.containerView addSubview:fromController.view];
        endFrame.origin.x += 370;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^(void) {
                             toController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
                             fromController.view.frame = endFrame;
                         }
                         completion:^(BOOL completed) {
                             [transitionContext completeTransition:YES];
                             [fromController.view removeFromSuperview];
                             [[[UIApplication sharedApplication] keyWindow] addSubview:toController.view];
                             
                         }
         ];
    }
}

@end