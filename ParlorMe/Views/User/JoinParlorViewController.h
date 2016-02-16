//
//  JoinParlorViewController.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@protocol RegsiterUserDelegate <NSObject>

- (void)addAddressForRegisteredUser;

@end

@interface JoinParlorViewController : UIViewController

@property(nonatomic,weak)   id delegate;

@end
