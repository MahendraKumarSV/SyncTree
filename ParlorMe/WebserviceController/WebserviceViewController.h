
//  WebserviceViewController.h
//  ParlorMe

#import <UIKit/UIKit.h>

@protocol WebserviceViewControllerDelegate <NSObject>

- (void)receivedResponse:(id)response;
- (void)failedWithError:(NSString*)errorTitle description:(NSString*)errorDescription;

@end

@interface WebserviceViewController : UIViewController

@property (nonatomic, weak) id<WebserviceViewControllerDelegate> delegate;

- (void)loginForUser:(NSString *)name andPassword:(NSString *)password;
- (void)registerUser:(NSDictionary*)postDictionary;
- (void)connectionHandler:(NSMutableURLRequest *)request;
- (void)forgotUserPassword:(NSDictionary*)postDictionary;
- (void)resetPassword:(NSDictionary*)postDictionary;
- (void)userMgmt;
- (void)getCategoryNames;
- (void)forgotStylistPassword:(NSDictionary*)postDictionary;
- (void)loginForStylist:(NSString *)name andPassword:(NSString *)password;
- (void)registerStylist:(NSDictionary*)postDictionary;
- (void)getStylistList;
- (void)getAddressList;
- (void)saveUserAddress:(NSDictionary*)postDictionary;
- (void)getClientToken;
- (void)getCreditCardList;
- (void)saveCreditCard:(NSString *)nonce;
- (void)makePayment:(NSDictionary*)postDictionary;
- (void)makeApplePayPayment:(NSDictionary*)postDictionary;
- (void)getUserDetails;
- (void)saveUserDetails:(NSDictionary*)postDictionary;
- (void)setSchedule:(NSDictionary *)postDictionary;
- (void)updateSchedule:(NSDictionary *)postDictionary andScheduleId:(NSString *)scheduleID;
- (void)getSchedule;
- (void)getStylistProfile;
- (void)updateProfile:(NSDictionary *)postDictionary;
- (void)createUserUsingFaceBook:(NSDictionary *)postDictionary;
- (void)checkIfFacebookUserExists:(NSDictionary *)postDictionary;
- (void)getServices;
- (void)addProduct:(NSString *)ID cost:(NSString *)price;
- (void)deleteProduct:(NSString *)ID;
- (void)getTimeSlotsForPartnerId:(NSString*)partnerId andForDate:(NSString *)selectedDate;
- (void)getAddressUsingGPS:(NSString*)urlString;
- (void)bookAppointment:(NSDictionary*)postDictionary;
- (void)getAppointmentID:(NSDictionary*)postDictionary;
- (void)cancelUserAppointment:(NSDictionary*)postDictionary;
- (void)sendStylist:(NSDictionary*)postDictionary;
- (void)clockInPartner;
- (void)partnerAvailability;
- (void)getAppointmentsCount;
- (void)getPartnerAppointmentsListsFromDate:(NSString *)selectedDate;
- (void)partnerConfirmAppointment:(NSDictionary *)appointment_id;
- (void)partnerCancelAppointment:(NSDictionary *)appointment_id;

@end

