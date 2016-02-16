//
//  StylistInfoViewController.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@class StylistDetails;

@protocol SetSelectedStylistDelegate <NSObject>

- (void)addtionalServiceSelected;
@optional
- (void)stylistSelected:(StylistDetails *)selectedStylist;

@end

@interface StylistInfoViewController : UIViewController

@property(nonatomic,retain) NSString *stylistId;
@property(nonatomic,retain) StylistDetails *stylistAC;
@property(nonatomic,weak)   id<SetSelectedStylistDelegate> delegate;

@end
