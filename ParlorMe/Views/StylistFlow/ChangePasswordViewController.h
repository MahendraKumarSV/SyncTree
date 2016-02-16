//
//  ChangePasswordViewController.h
//  ParlorMe
//
//  Created by sakshi on 15/12/15.
//  Copyright © 2015 dreamorbit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FetchChangedPassword <NSObject>

- (void)getStylistPassword:(NSString *)passwordString;

@end

@interface ChangePasswordViewController : UIViewController
@property (weak) id<FetchChangedPassword> delegate;
@end
