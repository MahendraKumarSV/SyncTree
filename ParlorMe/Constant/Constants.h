//
//  Constants.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

#define NetworkErrMsg   @"Currently network not available. Please try again"

#define DashedLineRGBColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#define IS_iPhone4SOR5 568.0
#define IS_iPhone6 667.0
#define IS_iPhone6Plus 736.0
#define Font8 8.0
#define Font9 9.0
#define Font10 10.0
#define Font11 11.0
#define Font12 12.0
#define Font13 13.0
#define Font14 14.0
#define Font15 15.0
#define Font16 16.0
#define Font17 17.0
#define Font18 18.0
#define Font19 19.0
#define Font20 20.0
#define Font21 21.0
#define Font22 22.0
#define Font23 23.0
#define Font24 24.0
#define Font25 25.0
#define Font26 26.0
#define Font27 27.0
#define Font28 28.0
#define Font29 29.0
#define Font30 30.0
#define Font31 31.0
#define Font32 32.0
#define Font33 33.0
#define Font34 34.0
#define Font35 35.0
#define Font36 36.0
#define Font37 37.0
#define Font38 38.0
#define Font39 39.0
#define Font40 40.0

@interface Constants:NSObject

extern NSString *const      kBaseUrl;
extern NSString *const      kNewUrl;
extern NSString *const      kRegister;
extern NSString *const      kLogin;
extern NSString *const      kAppId;
extern NSString *const      kForgotPassword;
extern NSString *const      kResetPassword;
extern NSString *const      kUserMgmt;
extern NSString *const      kCategoryList;
extern NSString *const      kForgotPasswordStylist;
extern NSString *const      kLoginStylist;
extern NSString *const      kRegisterStylist;
extern NSString *const      kGetStylistList;
extern NSString *const      kGetAddressList;
extern NSString *const      kSaveAddress;
extern NSString *const      kGetClientToken;
extern NSString *const      kGetCreditCardList;
extern NSString *const      kSaveCreditCard;
extern NSString *const      kMakePayment;
extern NSString *const      kMakeApplePayPayment;
extern NSString *const      kGetUserDetails;
extern NSString *const      kSaveUserDetails;
extern NSString *const      kSetPartnerSchedule;
extern NSString *const      kUpdatePartnerSchedule;
extern NSString *const      kGetPartnerSchedule;
extern NSString *const      kGetStylistProfile;
extern NSString *const      kUpdateStylistProfile;
extern NSString *const      kCreateUserUsingFacebook;
extern NSString *const      kCheckFacebookUser;
extern NSString *const      kFetchServices;
extern NSString *const      kAddProduct;
extern NSString *const      kDeleteProduct;
extern NSString *const      kGetTimeSlots;
extern NSString *const      kGetAddressUsingGPS;
extern NSString *const      kBookAppointment;
extern NSString *const      kGetAppointmentID;
extern NSString *const      kCancelUserAppointment;
extern NSString *const      kSendStylist;
extern NSString *const      kPartnerClockIn;
extern NSString *const      kisPartnerAvailable;
extern NSString *const      kPartnerAppointmentsCount;
extern NSString *const      kPartnerAppointmentsList;
extern NSString *const      kPartnerConfirmAppointment;
extern NSString *const      kPartnerCancelAppointment;

+(BOOL)isWifiAvailable;

@end
