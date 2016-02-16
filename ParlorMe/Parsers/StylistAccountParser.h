//
//  StylistAccountParser.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface StylistAccountParser : NSObject

@property (nonatomic, copy) NSString *isSetPartnerSchedule;
@property (nonatomic, copy) NSString *isUpdatePartnerSchedule;
@property (nonatomic, strong) NSString *isGetPartnerSchedule;
@property (nonatomic, strong) NSString *isGetStylistProfileResponse;
@property (nonatomic, strong) NSString *isUpdateStylistProfileResponse;
@property (nonatomic, strong) NSString *isGetCategoriesResponse;
@property (nonatomic, strong) NSString *isNewProductAdded;
@property (nonatomic, strong) NSString *isProductDeleted;
@property (nonatomic, strong) NSString *isPartnerClockIn;
@property (nonatomic, strong) NSString *isPartnerAvailable;
@property (nonatomic, strong) NSString *isPartnerAppointmentsCount;
@property (nonatomic, strong) NSString *isPartnerAppiontmentsListResponse;
@property (nonatomic, strong) NSString *isPartnerConfirmAppointment;
@property (nonatomic, strong) NSString *isPartnerCancelAppointment;

-(NSString *)parseStylistRegistrationResponse:(id)response;
-(NSString *)parseStylistLoginResponse:(id)response;
-(NSString *)parseStylistForgotPasswordResponse:(id)response;
-(NSString *)parseStylistList:(id)response;
-(NSString *)parseSetPartnerScheduleResponse:(id)response;
-(NSString *)parseUpdatePartnerScheduleResponse:(id)response;
-(NSString *)parseGetPartnerScheduleResponse:(id)response;
-(NSString *)parseGetStylistProfileResponse:(id)response;
-(NSString *)parseGetCategoriesResponse:(id)response;
-(NSString *)parseAddProductResponse:(id)response;
-(NSString *)parseDeleteProductResponse:(id)response;
-(NSString *)parseUpdateStylistProfileResponse:(id)response;
-(NSString *)parseGetTimeSlotsResponse:(id)response;
-(NSString *)parsePartnerClockIn:(id)response;
-(NSString *)parsePartnerAvailability:(id)response;
-(NSString *)parsePartnerAppointmentsCount:(id)response;
-(NSString *)parsePartnerAppointmentsList:(id)response;
-(NSString *)parsePartnerConfirmAppointment:(id)response;
-(NSString *)parsePartnerCancelAppointment:(id)response;

@end
