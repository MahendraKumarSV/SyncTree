
//  Utility.h
//  ParlorMe

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+ (void) removeActivityIndicator;
+ (void) showActivityIndicator:(UIView *)view;
+ (void)showActivity:(UIViewController *)viewController;

@end
