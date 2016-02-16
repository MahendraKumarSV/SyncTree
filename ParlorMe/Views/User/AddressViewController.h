//
//  AddressViewController.h
//  ParlorMe

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SaveAddressDelegate <NSObject>

- (void)getNewlySavedAddress;

@end

@interface AddressViewController : UIViewController

@property(nonatomic, weak) id delegate;

@end
