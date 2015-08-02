//
//  MainAnimationTransition.m
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 8/1/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainAnimationTransition.h"

@implementation MainAnimationTransition

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    return self;
}


- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    return self;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    // reset state
    self.isPresenting = NO;
}



- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"Yooo");
    
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect endFrame = fromController.view.frame;
   
    if(self.isPresenting) {
        fromController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromController.view];
        [transitionContext.containerView addSubview:toController.view];
        
        CGRect startFrame = endFrame;
        startFrame.origin.x += 320;
        
        toController.view.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toController.view.frame = endFrame;
        }completion:^(BOOL completed) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toController.view];
        [transitionContext.containerView addSubview:fromController.view];
        
        endFrame.origin.x += 320;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^(void) {
            toController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            fromController.view.frame = endFrame;
        }completion:^(BOOL completed) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

@end
