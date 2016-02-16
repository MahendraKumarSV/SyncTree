//
//  SingletonClass.h
//  ParlorMe
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MessageUI/MessageUI.h>

@interface SingletonClass : NSObject<MFMailComposeViewControllerDelegate>
{
    UIViewController *curentVC;
}

@property (nonatomic) BOOL dropDownBoolValue;
@property (nonatomic) BOOL appoinmentNotification;
@property (nonatomic, strong) NSDictionary *getPartnerScheduleResponse;
@property (nonatomic) int updateScheduleStatusCode;
@property (nonatomic) NSMutableArray *tempRepeatedDaysArray;
@property (nonatomic) NSMutableArray *fetchServicesFromResponse;
@property (nonatomic) NSString *productAdded;
@property (nonatomic) NSString *directSignUp;
@property (nonatomic) NSMutableArray *stylistList;;

+(SingletonClass*)shareManager;
-(void)showBackBtn:(UIViewController *)vc;

@end
