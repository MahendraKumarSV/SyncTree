//
//  Constants.m
//  ParlorMe
//

#import "Constants.h"
#import "Reachability.h"

@implementation Constants

NSString *const      kBaseUrl = @"http://parlorme.synctree.com";
NSString *const      kNewUrl = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=12.9667,77.5667";
NSString *const      kRegister = @"Register";
NSString *const      kLogin = @"Login";
NSString *const      kAppId = @"b27d41052bec1e29a15ea32c35e0299c48ed59c38006566c93b2ff8cf2495fec";
NSString *const      kForgotPassword = @"ForgotPassword";
NSString *const      kResetPassword = @"ResetPassword";
NSString *const      kUserMgmt = @"UserMgmt";
NSString *const      kCategoryList = @"CategoryList";
NSString *const      kForgotPasswordStylist = @"ForgotPasswordStylist";
NSString *const      kLoginStylist = @"LoginStylist";
NSString *const      kRegisterStylist = @"RegisterStylist";
NSString *const      kGetStylistList = @"GetStylistList";
NSString *const      kGetAddressList = @"GetAddressList";
NSString *const      kSaveAddress = @"SaveAddress";
NSString *const      kGetClientToken = @"GetClientToken";
NSString *const      kGetCreditCardList = @"GetCreditCardList";
NSString *const      kSaveCreditCard = @"SaveCreditCard";
NSString *const      kMakePayment = @"MakePayment";
NSString *const      kMakeApplePayPayment = @"MakeApplePayPayment";
NSString *const      kGetUserDetails = @"GetUserDetails";
NSString *const      kSaveUserDetails = @"SaveUserDetails";
NSString *const      kSetPartnerSchedule = @"SetSchedule";
NSString *const      kUpdatePartnerSchedule = @"UpdateSchedule";
NSString *const      kGetPartnerSchedule = @"GetSchedule";
NSString *const      kGetStylistProfile = @"GetStylistProfile";
NSString *const      kUpdateStylistProfile = @"UpdateStylistProfile";
NSString *const      kCreateUserUsingFacebook = @"CreateUserUsingFaceBook";
NSString *const      kCheckFacebookUser = @"CheckFacebookUser";
NSString *const      kFetchServices = @"FetchServices";
NSString *const      kAddProduct    = @"NewProductAdded";
NSString *const      kDeleteProduct = @"ProductDeleted";
NSString *const      kGetTimeSlots  = @"GetTimeSlots";
NSString *const      kGetAddressUsingGPS = @"GetAddressUsingGPS";
NSString *const      kBookAppointment = @"BookAppointment";
NSString *const      kGetAppointmentID = @"GetAppointmentID";
NSString *const      kCancelUserAppointment = @"CancelUserAppointment";
NSString *const      kSendStylist = @"SendStylist";
NSString *const      kPartnerClockIn   = @"PartnerClockIn";
NSString *const      kPartnerAppointmentsCount  = @"PartnerAppointmentsCount";
NSString *const      kisPartnerAvailable = @"PartnerAvailable";
NSString *const      kPartnerAppointmentsList = @"AppointmentsList";
NSString *const      kPartnerConfirmAppointment = @"ConfirmAppointment";
NSString *const      kPartnerCancelAppointment = @"CancelAppointment";

// to check if WIFI Available
+(BOOL)isWifiAvailable
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    if(![r currentReachabilityStatus] == NotReachable || [r currentReachabilityStatus] == ReachableViaWiFi ||
       [r currentReachabilityStatus] == ReachableViaWWAN)
        return YES;
    else
        return NO;
}

@end
