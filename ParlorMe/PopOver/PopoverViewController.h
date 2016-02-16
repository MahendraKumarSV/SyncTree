//
//  PopoverViewController.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@protocol PopOverDelegate <NSObject>

- (void)dismissPopOverView;

@end

@interface PopoverViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *goBtn;
@property (retain, nonatomic)id delegate;

@end
