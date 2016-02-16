//
//  UserAccountParser.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface UserAccountParser : NSObject

@property (nonatomic, copy) NSString *isUserMgmtSuccessful;
@property (nonatomic, copy) NSString *isResetPasswordSuccessful;

-(NSString *)parseRegistrationResponse:(id)response;
-(NSString *)parseLoginResponse:(id)response;
-(NSString *)parseResetPasswordResponse:(id)response;
-(NSString *)parseForgotPasswordResponse:(id)response;
-(NSString *)parseUserMgmtResponse:(id)response;
-(NSString *)parseCategoryResponse:(id)response;
-(NSString *)parseGetAddressListResponse:(id)response;
-(NSString *)parseSaveAddressResponse:(id)response;
-(NSString *)parseGetClientTokenResponse:(id)response;
-(NSString *)parseGetCreditCardListResponse:(id)response;
-(NSString *)parseSaveCreditCardResponse:(id)response;
-(NSString *)parseMakePaymentResponse:(id)response;
-(NSString *)parseGetUserDetailsResponse:(id)response;
-(NSString *)parseSaveUserDetailsResponse:(id)response;
-(NSString *)parseCreateUserUsingFacebookResponse:(id)response;
-(NSString *)checkIfFacebookUser:(id)response;
-(NSString *)parseGetAddressUsingGPSresponse:(id)response;
-(NSString *)parseBookAppointmentResponse:(id)response;
-(NSString *)parseGetAppointmentIDResponse:(id)response;
-(NSString *)parseCancelAppointmentAPIResponse:(id)response;
-(NSString *)parseSendStylistNowResponse:(id)response;

@end
