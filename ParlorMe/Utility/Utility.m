
//  Utility.m
//  ParlorMe

#import "Utility.h"
#import <UIKit/UIKit.h>

@implementation Utility

static UIActivityIndicatorView* activityIndicator;
static UIView* backgroundView;

#pragma mark - Activity Indicator related Methods
// To show Activity Indicator
+ (void) showActivityIndicator:(UIView *)view
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if(activityIndicator == nil)
    {
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height+50)];
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    activityIndicator.color = [UIColor lightGrayColor];
    CGRect rect = CGRectMake((view.frame.size.width/2), (view.frame.size.height/2), 130, 170);
    activityIndicator.frame = rect;
    activityIndicator.center = CGPointMake(view.center.x, view.center.y);
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    [backgroundView addSubview:activityIndicator];
    [view addSubview:backgroundView];
}

+ (void)showActivity:(UIViewController *)viewController
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if(activityIndicator == nil)
    {
        //NSLog(@"height: %f",viewController.view.frame.size.height);
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height+100)];
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    activityIndicator.color = [UIColor lightGrayColor];
    CGRect rect = CGRectMake((viewController.view.frame.size.width/2), (viewController.view.frame.size.height/2), 130, 170);
    activityIndicator.frame = rect;
    activityIndicator.center = CGPointMake(viewController.view.center.x, viewController.view.center.y);
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    [backgroundView addSubview:activityIndicator];
    [[UIApplication sharedApplication].keyWindow addSubview:backgroundView];
}

// To remove Activity Indicator
+ (void) removeActivityIndicator
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    [backgroundView removeFromSuperview];
    backgroundView = nil;
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}

@end
