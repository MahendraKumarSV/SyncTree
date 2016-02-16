//
//  AddCreditCardViewController.h
//  ParlorMe

#import <UIKit/UIKit.h>
#import <Braintree/Braintree.h>

@protocol SaveCreditCardDelegate <NSObject>

- (void)getSavedCreditCards;

@end

@interface AddCreditCardViewController : UIViewController

@property(nonatomic,weak) id<SaveCreditCardDelegate> delegate;
@property (nonatomic, strong) NSString *clientToken;

@end
