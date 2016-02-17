
//  WebserviceViewController.m
//  ParlorMe

#import "WebserviceViewController.h"
#import "Constants.h"
#import "UserAccountParser.h"
#import "StylistAccountParser.h"
#import "UserAccount.h"
#import "SingletonClass.h"
#import "StylistAccount.h"

@interface WebserviceViewController ()
{
    SingletonClass *sharedObj;
}

@property (nonatomic, strong) NSMutableURLRequest* request;
@property (nonatomic, strong) NSString* mode;

@end

@implementation WebserviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //  self.navigationController.navigationBarHidden=TRUE;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PUT Request
- (void)modifyDataInPath:(NSString *)path withData:(NSData*)postBody
{
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.request setHTTPMethod:@"PUT"];
    self.request.timeoutInterval = 40;
    [self.request setHTTPBody:postBody];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postBody length]];
    [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //   [self.request addRequestHeader:@"X-HTTP-Method-Override" value:@"PATCH"];
    [self.request setValue:@"PATCH" forHTTPHeaderField:@"X-HTTP-Method-Override"];
    [self connectionHandler:self.request];
}

#pragma mark - POST Request
// calling URL with details like data and data length with post request
- (void)postDataInPath:(NSString *)path withData:(NSData*) postBody withContentType:(NSString*)contentType
{
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postBody length]];
    [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    self.request.timeoutInterval = 40;
    [self.request setHTTPBody:postBody];
    [self.request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [self connectionHandler:self.request];
}

#pragma mark - GET Request
//calling URL with get request
- (void)requestDataInPath:(NSString *)path
{
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.request setHTTPMethod:@"GET"];
    self.request.timeoutInterval = 40;
    [self connectionHandler:self.request];
}

#pragma mark - Connection Handler
// Checking and parsing received response
- (void) connectionHandler:(NSMutableURLRequest *)request
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       // Peform the request
                       NSURLResponse *response;
                       NSError *error = nil;
                       NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                                    returningResponse:&response
                                                                                error:&error];
                       //NSLog(@"Error-->%@",error);
                       if (error) {
                           // Checking Error
                           if ([response isKindOfClass:[NSHTTPURLResponse class]])
                           {
                               //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                               //NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, error);
                               [self.delegate failedWithError:@"Unable to process your request." description:error.localizedDescription];
                               return;
                           }
                           else if (error.code == -1009)
                           {
                               [self.delegate failedWithError:@"Network Not Reachable." description:@"The Internet connection appears to be offline"];
                               return;
                           }
                           else if (error.code == 500 || error.code == 502)
                           {
                               [self.delegate failedWithError:@"Unable to process request." description:@"Server error"];
                               return;
                           }
                           else if (error.code == 401)
                           {
                               [self.delegate failedWithError:@"Unable to process request." description:@"Unauthorized"];
                               return;
                           }
                           else if (error.code == 406)
                           {
                               [self.delegate failedWithError:@"Unable to process request." description:@"Not acceptable"];
                               return;
                           }
                           else if (error.code == 422)
                           {
                               [self.delegate failedWithError:@"Unable to process request." description:@"Unprocessable entity"];
                               return;
                           }
                           else if (error.code == -1005)
                           {
                               [self.delegate failedWithError:@"Network Not Reachable." description:@"The Internet connection appears to be offline"];
                               return;
                           }
                           
                           else if (error.code == -1012)
                           {
                               [self.delegate failedWithError:@"Session Expired" description:@"Please re-login to continue"];
                               return;
                               /*UIAlertView *expiresSessionAlert = [[UIAlertView alloc]initWithTitle:@"Session Expired" message:@"Please re-login to continue" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                               expiresSessionAlert.tag = 1000;
                               [expiresSessionAlert show];*/
                           }
                           
                           else
                           {
                               [self.delegate failedWithError:@"Unable to process request." description:error.localizedDescription];
                               return;
                           }
                       }
                       
                       //NSLog(@"Response --> %@",response);
                       //NSLog(@"Data receieved -->%@",receivedData);
                       
                       NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                       int responseStatusCode = (int)[httpResponse statusCode];
                       NSString *alertMsg = [NSString stringWithFormat:@"Something went wrong, Error Code %d",responseStatusCode];
                       NSDictionary *myData = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:Nil];
                       //NSLog(@"%@",myData);
                       
                       // checking if request failed
                       if(responseStatusCode != 200)
                       {
                           [self.delegate failedWithError:@"Unable to process request." description:alertMsg];
                           return;
                       }
                       //Parse and return user registration response
                       if (self.mode == kRegister)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isUserRegistrationSuccessful = [userAcccountParser parseRegistrationResponse:receivedData];
                                              [self.delegate receivedResponse:isUserRegistrationSuccessful];
                                          });
                       }
                       // Parse and return user login response
                       else if (self.mode == kLogin)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser* userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isLoginSuccessful = [userAcccountParser parseLoginResponse:receivedData];
                                              [self.delegate receivedResponse:isLoginSuccessful];
                                          });
                       }
                       // Parse and return user forgot password response
                       else if (self.mode == kForgotPassword)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser* userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isForgotPasswordSuccessful = [userAcccountParser parseForgotPasswordResponse:receivedData];
                                              [self.delegate receivedResponse:isForgotPasswordSuccessful];
                                          });
                       }
                       // Parse and return user reset password response
                       else if (self.mode == kResetPassword)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser* userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isResetPasswordSuccessful = [userAcccountParser parseResetPasswordResponse:receivedData];
                                              [self.delegate receivedResponse:isResetPasswordSuccessful];
                                          });
                       }
                       // Parse and return user management response
                       else if (self.mode == kUserMgmt)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser* userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isUserMgmtSuccessful = [userAcccountParser parseUserMgmtResponse:receivedData];
                                              [self.delegate receivedResponse:isUserMgmtSuccessful];
                                          });
                       }
                       // Parse and return stylist registration response
                       else if (self.mode == kRegisterStylist)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isUserRegistrationSuccessful = [stylistAccountParser parseStylistRegistrationResponse:receivedData];
                                              [self.delegate receivedResponse:isUserRegistrationSuccessful];
                                          });
                       }
                       // Parse and return stylist login response
                       else if (self.mode == kLoginStylist)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser* stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isLoginSuccessful = [stylistAccountParser parseStylistLoginResponse:receivedData];
                                              [self.delegate receivedResponse:isLoginSuccessful];
                                              
                                          });
                       }
                       // Parse and return stylist forgot password response
                       else if (self.mode == kForgotPasswordStylist)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser* stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isForgotPasswordSuccessful = [stylistAccountParser parseStylistForgotPasswordResponse:receivedData];
                                              [self.delegate receivedResponse:isForgotPasswordSuccessful];
                                          });
                       }
                       // Parse and return Category response
                       else if (self.mode == kCategoryList)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser * userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString* isCategoryListFound = [userAcccountParser parseCategoryResponse:receivedData];
                                              [self.delegate receivedResponse:isCategoryListFound];
                                          });
                       }
                       // Parse and return StylistList response
                       else if (self.mode == kGetStylistList)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isStylistListFound = [stylistAccountParser parseStylistList:receivedData];
                                              [self.delegate receivedResponse:isStylistListFound];
                                          });
                       }
                       // Parse and return get AddressList response
                       else if (self.mode == kGetAddressList)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAddressListFound = [userAcccountParser parseGetAddressListResponse:receivedData];
                                              [self.delegate receivedResponse:isAddressListFound];
                                          });
                       }
                       // Parse and return Save Address response
                       else if (self.mode == kSaveAddress)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAddressSaved = [userAcccountParser parseSaveAddressResponse:receivedData];
                                              [self.delegate receivedResponse:isAddressSaved];
                                          });
                       }
                       // Parse and return Get Client Token  response
                       else if (self.mode == kGetClientToken)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isClientTokenRecieved = [userAcccountParser parseGetClientTokenResponse:receivedData];
                                              [self.delegate receivedResponse:isClientTokenRecieved];
                                          });
                       }
                       // Parse and return Get CreditCard List response
                       else if (self.mode == kGetCreditCardList)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isCreditCardListFound = [userAcccountParser parseGetCreditCardListResponse:receivedData];
                                              [self.delegate receivedResponse:isCreditCardListFound];
                                          });
                       }
                       // Parse and return Saved CreditCard List response
                       else if (self.mode == kSaveCreditCard)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isSaveCreditCardSuccessful = [userAcccountParser parseSaveCreditCardResponse:receivedData];
                                              [self.delegate receivedResponse:isSaveCreditCardSuccessful];
                                          });
                       }
                       // Parse and return Make Payment response
                       else if (self.mode == kMakePayment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isPayementSuccessful = [userAcccountParser parseMakePaymentResponse:receivedData];
                                              [self.delegate receivedResponse:isPayementSuccessful];
                                          });
                       }
                       // Parse and return Make Apple Pay Payment response
                       else if (self.mode == kMakeApplePayPayment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isPayementSuccessful = [userAcccountParser parseMakePaymentResponse:receivedData];
                                              [self.delegate receivedResponse:isPayementSuccessful];
                                          });
                       }
                       // Parse and return Get User Details response
                       else if (self.mode == kGetUserDetails)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isGetDetails = [userAcccountParser parseGetUserDetailsResponse:receivedData];
                                              [self.delegate receivedResponse:isGetDetails];
                                          });
                       }
                       // Parse and return Save User Details response
                       else if (self.mode == kSaveUserDetails)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isSaveDetails = [userAcccountParser parseSaveUserDetailsResponse:receivedData];
                                              [self.delegate receivedResponse:isSaveDetails];
                                          });
                       }
                       // Parse and return Created User Using Facebook Details response
                       else if (self.mode == kCreateUserUsingFacebook)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isUserCreated = [userAcccountParser parseCreateUserUsingFacebookResponse:receivedData];
                                              [self.delegate receivedResponse:isUserCreated];
                                          });
                       }
                       // Parse and return Check if facebook user details present response
                       else if (self.mode == kCheckFacebookUser)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isUserPresent = [userAcccountParser checkIfFacebookUser:receivedData];
                                              [self.delegate receivedResponse:isUserPresent];
                                          });
                       }
                       // Parse and return Available time slots
                       else if (self.mode == kGetTimeSlots)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser *stylistAcccountParser = [[StylistAccountParser alloc] init];
                                              NSString *isTimeSlotsAvailable = [stylistAcccountParser parseGetTimeSlotsResponse:receivedData];
                                              [self.delegate receivedResponse:isTimeSlotsAvailable];
                                          });
                       }
                       // Parse and return Get Address Using GPS
                       else if (self.mode == kGetAddressUsingGPS)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isGPSAddressAvailable = [userAcccountParser parseGetAddressUsingGPSresponse:receivedData];
                                              [self.delegate receivedResponse:isGPSAddressAvailable];
                                          });
                       }
                       // Parse and return Book Appointment response
                       else if (self.mode == kBookAppointment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAppointmentBooked = [userAcccountParser parseBookAppointmentResponse:receivedData];
                                              [self.delegate receivedResponse:isAppointmentBooked];
                                          });
                       }
                       // Parse and return Get Appointment ID response
                       else if (self.mode == kGetAppointmentID)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAppointmentBooked = [userAcccountParser parseGetAppointmentIDResponse:receivedData];
                                              [self.delegate receivedResponse:isAppointmentBooked];
                                          });
                       }
                       // Parse and return Send Stylist Now response
                       else if (self.mode == kSendStylist)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAppointmentBooked = [userAcccountParser parseSendStylistNowResponse:receivedData];
                                              [self.delegate receivedResponse:isAppointmentBooked];
                                          });
                       }

                       // Parse and return Cancel Appointment API response
                       else if (self.mode == kCancelUserAppointment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              UserAccountParser *userAcccountParser = [[UserAccountParser alloc] init];
                                              NSString *isAppointmentCancelled = [userAcccountParser parseCancelAppointmentAPIResponse:receivedData];
                                              [self.delegate receivedResponse:isAppointmentCancelled];
                                          });
                       }
                       // Parse and return Get Partner Schedule Response
                       else if (self.mode == kGetPartnerSchedule)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              sharedObj = [SingletonClass shareManager];
                                              sharedObj.getPartnerScheduleResponse = myData;
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isStylistGetPartnerScheduleFound = [stylistAccountParser parseGetPartnerScheduleResponse:receivedData];
                                              [self.delegate receivedResponse:isStylistGetPartnerScheduleFound];
                                          });
                       }
                       // Parse and return Set Partner Schedule Response
                       else if (self.mode == kSetPartnerSchedule)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isStylistSetPartnerScheduleFound = [stylistAccountParser parseSetPartnerScheduleResponse:receivedData];
                                              [self.delegate receivedResponse:isStylistSetPartnerScheduleFound];
                                          });
                       }
                       // Parse and return Update Partner Schedule Response
                       else if (self.mode == kUpdatePartnerSchedule)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isStylistUpdatePartnerScheduleFound = [stylistAccountParser parseUpdatePartnerScheduleResponse:receivedData];
                                              sharedObj = [SingletonClass shareManager];
                                              sharedObj.updateScheduleStatusCode = responseStatusCode;
                                              [self.delegate receivedResponse:isStylistUpdatePartnerScheduleFound];
                                          });
                       }
                       // Parse and return Get Stylist Profile Response
                       else if (self.mode == kGetStylistProfile)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isGetStylistProfileFound = [stylistAccountParser parseGetStylistProfileResponse:receivedData];
                                              [self.delegate receivedResponse:isGetStylistProfileFound];
                                          });
                       }
                       // Parse and return Get Stylist Services Response
                       else if (self.mode == kFetchServices)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isGetCategoriesFound = [stylistAccountParser parseGetCategoriesResponse:receivedData];
                                              sharedObj = [SingletonClass shareManager];
                                              sharedObj.fetchServicesFromResponse = [myData objectForKey:@"services"];
                                              [self.delegate receivedResponse:isGetCategoriesFound];
                                          });
                       }
                       // Parse and return Add Product Response
                       else if (self.mode == kAddProduct)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isNewProductAdded = [stylistAccountParser parseAddProductResponse:receivedData];
                                              [self.delegate receivedResponse:isNewProductAdded];
                                          });
                       }
                       // Parse and return Update Stylist Profile Response
                       else if (self.mode == kUpdateStylistProfile)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isUpdateStylistProfileFound = [stylistAccountParser parseUpdateStylistProfileResponse:receivedData];
                                              [self.delegate receivedResponse:isUpdateStylistProfileFound];
                                          });
                       }
                       // Parse and return Delete Product Response
                       else if (self.mode == kDeleteProduct)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isProductDeleted = [stylistAccountParser parseDeleteProductResponse:receivedData];
                                              [self.delegate receivedResponse:isProductDeleted];
                                          });
                       }
                       
                       else if (self.mode == kPartnerClockIn)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isPartnerClockIn = [stylistAccountParser parsePartnerClockIn:receivedData];
                                              [self.delegate receivedResponse:isPartnerClockIn];
                                          });
                       }
                       
                       else if (self.mode == kisPartnerAvailable)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isPartnerAvailable = [stylistAccountParser parsePartnerAvailability:receivedData];
                                              [self.delegate receivedResponse:isPartnerAvailable];
                                          });
                       }
                       
                       else if (self.mode == kPartnerAppointmentsCount)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isPartnerAppointmentsCountExists = [stylistAccountParser parsePartnerAppointmentsCount:receivedData];
                                              [self.delegate receivedResponse:isPartnerAppointmentsCountExists];
                                              StylistAccount *stylistAC = [StylistAccount sharedInstance];
                                              
                                              NSMutableArray *keysArray = [[NSMutableArray alloc] init];
                                              NSArray * keys = [myData allKeys];
                                              [keysArray addObject:keys];
                                              stylistAC.stylistAppointmentDatesArray = [keysArray objectAtIndex:0];
                                              
                                              NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
                                              NSArray * values = [myData allValues];
                                              [valuesArray addObject:values];
                                              stylistAC.stylistAppointmentCountArray = [valuesArray objectAtIndex:0];
                                              
                                              //NSLog(@"response stylistAppointmentDatesArray: %@",stylistAC.stylistAppointmentDatesArray);
                                              //NSLog(@"response stylistAppointmentCountArray: %@",stylistAC.stylistAppointmentCountArray);
                                          });
                       }
                       
                       else if (self.mode == kPartnerAppointmentsList)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isPartnerAppointmentListExists = [stylistAccountParser parsePartnerAppointmentsList:receivedData];
                                              [self.delegate receivedResponse:isPartnerAppointmentListExists];
                                          });
                       }
                       
                       else if (self.mode == kPartnerConfirmAppointment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isAppointmentConfirmed = [stylistAccountParser parsePartnerConfirmAppointment:receivedData];
                                              [self.delegate receivedResponse:isAppointmentConfirmed];
                                          });
                       }
                       
                       else if (self.mode == kPartnerCancelAppointment)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              StylistAccountParser * stylistAccountParser = [[StylistAccountParser alloc] init];
                                              NSString* isAppointmentCancelled = [stylistAccountParser parsePartnerCancelAppointment:receivedData];
                                              [self.delegate receivedResponse:isAppointmentCancelled];
                                          });
                       }
                   });
}

#pragma mark - User Flow related Methods

// Call Login User API
- (void)loginForUser:(NSString *)name andPassword:(NSString *)password
{
    self.mode = kLogin;
    NSString *endUrl = @"api/v1/clients/login";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    // Checking if user provided email id or mobile number
    if([name rangeOfString:@"."].location != NSNotFound)
    {
        [userDictionary setObject:[name lowercaseString] forKey:@"email"];
    }
    else
    {
        [userDictionary setObject:name forKey:@"mobile_phone"];
    }
    [userDictionary setObject:password forKey:@"password"];
    
    //forming Json Object
    [postDictionary setObject:kAppId forKey:@"app_id"];
    [postDictionary setObject:userDictionary forKey:@"client"];
    
    // Converting Json Object to NSData
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    
    // Firing POST Request
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Register User API
- (void)registerUser:(NSDictionary*)postDictionary
{
    self.mode = kRegister;
    NSString *endUrl = @"api/v1/clients";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSString *contentType = @"application/json";
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:contentType];
}

// Call Forgot User Password API
- (void)forgotUserPassword:(NSDictionary*)postDictionary
{
    self.mode = kForgotPassword;
    NSString *endUrl = @"api/v1/clients/forgot_password";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Reset User Password API
- (void)resetPassword:(NSDictionary*)postDictionary
{
    self.mode = kResetPassword;
    NSString *endUrl = @"api/v1/users/reset_password";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call User Management API
- (void)userMgmt
{
    self.mode = kUserMgmt;
    NSString *endUrl = @"api/v1/users";
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    NSString *completeId = [NSString stringWithFormat:@"%@?access_token=%@", userId,accessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",kBaseUrl,endUrl,completeId];
    // NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //   NSLog(@"%@",postDictionary);
    [self requestDataInPath:urlString];
}

// Call Get User Details API
- (void)getUserDetails
{
    self.mode = kGetUserDetails;
    NSString *endUrl = @"api/v1/clients";
    UserAccount *userAccount = [UserAccount sharedInstance];
    //NSLog(@"accessToken: %@",userAccount.accessToken);//55b09fb369702d49bb000000
    //userAccount.accessToken = @"87c2a43a9bd67df91e694d0e1271b88d633c565366f26801a7e90fd70b236ee8";
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.userId,userAccount.accessToken];
    [self requestDataInPath:urlString];
}

// Call Save User Details API
- (void)saveUserDetails:(NSDictionary*)postDictionary
{
    self.mode = kSaveUserDetails;
    NSString *endUrl = @"api/v1/clients";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.userId,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    [self modifyDataInPath:encodedUrlString withData:postData];
}

#pragma mark - Stylist Flow related Methods

// Call Register Stylist API
- (void)registerStylist:(NSDictionary*)postDictionary
{
    self.mode = kRegisterStylist;
    NSString *endUrl = @"api/v1/partners";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSString *contentType =@"application/json";
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:contentType];
}

// Call Login Stylist API
- (void)loginForStylist:(NSString *)name andPassword:(NSString *)password
{
    self.mode = kLoginStylist;
    NSString *endUrl = @"api/v1/partners/login";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    
    if([name rangeOfString:@"."].location != NSNotFound)
    {
        [userDictionary setObject:[name lowercaseString] forKey:@"email"];
    }
    
    else
    {
        [userDictionary setObject:name forKey:@"mobile_phone"];
    }
    
    [userDictionary setObject:password forKey:@"password"];
    [postDictionary setObject:kAppId forKey:@"app_id"];
    [postDictionary setObject:userDictionary forKey:@"partner"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"postDictionary: %@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Forgot Stylist Password API
- (void)forgotStylistPassword:(NSDictionary*)postDictionary
{
    self.mode = kForgotPasswordStylist;
    NSString *endUrl = @"api/v1/partners/forgot_password";
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"%@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

#pragma mark - Services Wizard/Tab Related Methods

// Call Get Category Name API
- (void)getCategoryNames
{
    self.mode = kCategoryList;
    NSString *endUrl = @"api/v1/categories";
    //UserAccount *userAccount = [UserAccount sharedInstance];
    //NSString *completeId = [NSString stringWithFormat:@"?app_id=%@&access_token=%@",kAppId,userAccount.accessToken];
    NSString *completeId = [NSString stringWithFormat:@"?app_id=%@",kAppId];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@",kBaseUrl,endUrl,completeId];
    //NSLog(@"getCategoryNames urlString: %@",urlString);
    [self requestDataInPath:urlString];
}

// Call Get Stylist List API
- (void)getStylistList
{
    NSString *urlString;
    self.mode = kGetStylistList;
    NSString *endUrl = @"api/v1/services";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    // converting array into string seperated by comma
    NSString *servicesList = [[userAccount.selectedServicesList.allKeys valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *encodedString = [servicesList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //userAccount.userLocationPincode = @"33404";
    
    if(userAccount.userLocationPincode)
       urlString = [NSString stringWithFormat:@"%@/%@?app_id=%@&services=%@&location=%@",kBaseUrl,endUrl,kAppId,encodedString,userAccount.userLocationPincode];
    else
       urlString = [NSString stringWithFormat:@"%@/%@?app_id=%@&services=%@",kBaseUrl,endUrl,kAppId,encodedString];
    
    NSLog(@"urlString: %@",urlString);
        
    [self requestDataInPath:urlString];
}

#pragma mark - Address API related Methods

// Call Get Address List API
- (void)getAddressList
{
    self.mode = kGetAddressList;
    NSString *endUrl = @"api/v1/users";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/addresses?access_token=%@",kBaseUrl,endUrl,userAccount.userId,userAccount.accessToken];
    [self requestDataInPath:urlString];
}

// Call Save User Address API
- (void)saveUserAddress:(NSDictionary*)postDictionary
{
    self.mode = kSaveAddress;
    NSString *endUrl = @"api/v1/users";
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/addresses?access_token=%@",kBaseUrl,endUrl,userAccount.userId,userAccount.accessToken];
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Get Address Using GPS API
- (void)getAddressUsingGPS:(NSString*)urlString
{
    self.mode = kGetAddressUsingGPS;
    [self requestDataInPath:urlString];
}

#pragma mark - Payment API related Methods

// Call Get Client token API
- (void)getClientToken
{
    self.mode = kGetClientToken;
    NSString *endUrl = @"api/v1/transactions/new";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    [self requestDataInPath:urlString];
}

// Call Get Credit Card List API
- (void)getCreditCardList
{
    self.mode = kGetCreditCardList;
    NSString *endUrl = @"api/v1/transactions";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/get_creditcard_details?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self requestDataInPath:encodedUrlString];
}

// Call Save Credit Card API
- (void)saveCreditCard:(NSString *)nonce
{
    self.mode = kSaveCreditCard;
    NSString *endUrl = @"api/v1/transactions";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObject:nonce forKey:@"payment_method_nonce"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/save_credit_card?payment_method_nonce=%@&access_token=%@",kBaseUrl,endUrl,nonce,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

// Call Make Credit Card Payment API
- (void)makePayment:(NSDictionary*)postDictionary
{
    self.mode = kMakePayment;
    NSString *endUrl = @"api/v1/transactions";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

// Call Make Apple Pay Payment API
- (void)makeApplePayPayment:(NSDictionary*)postDictionary
{
    self.mode = kMakeApplePayPayment;
    NSString *endUrl = @"api/v1/transactions";
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

#pragma mark - Stylist Schedule API related Methods

// Call Set Stylist Schedule API
-(void)setSchedule:(NSDictionary *)postDictionary
{
    self.mode = kSetPartnerSchedule;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@/schedules/set_schedule?access_token=%@",stylistAC.userId,stylistAC.accessToken];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    //NSLog(@"set schedule endUrl: %@",endUrl);
    //NSLog(@"setSchedule: %@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Update Stylist Schedule API
-(void)updateSchedule:(NSDictionary *)postDictionary andScheduleId:(NSString *)scheduleID
{
    self.mode = kUpdatePartnerSchedule;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@/schedules/%@/update_schedule?access_token=%@",stylistAC.userId, scheduleID, stylistAC.accessToken];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"update schedule endUrl: %@",urlString);
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    //NSLog(@"updateSchedule: %@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Get Stylist Schedule API
-(void)getSchedule
{
    self.mode = kGetPartnerSchedule;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSLog(@"accessToken: %@",stylistAC.accessToken);
    //stylistAC.accessToken = @"87c2a43a9bd67df91e694d0e1271b88d633c565366f26801a7e90fd70b236ee8";
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@/schedules/get_schedule?access_token=%@",stylistAC.userId,stylistAC.accessToken];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"getSchedule: %@",urlString);
    
    [self requestDataInPath:urlString];
}

#pragma mark - Stylist Profile API related Methods

// Call Get Stylist Profile API
- (void)getStylistProfile
{
    self.mode = kGetStylistProfile;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@",stylistAC.userId];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,stylistAC.accessToken];
    
    //NSLog(@"get stylist profile: %@",urlString);
    
    [self requestDataInPath:urlString];
}

// Call Update Stylist Profile API
-(void)updateProfile:(NSDictionary *)postDictionary
{
    self.mode = kUpdateStylistProfile;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@",stylistAC.userId];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,stylistAC.accessToken];
    //NSLog(@"updateProfile: %@",urlString);
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    [self modifyDataInPath:encodedUrlString withData:postData];
}

#pragma mark - Facebook API related Methods

// Call Register using Facebook API
- (void)createUserUsingFaceBook:(NSDictionary *)postDictionary
{
    self.mode = kCreateUserUsingFacebook;
    NSString *endUrl = @"api/v1/clients/fb_login";
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    //NSLog(@"create user using fb: %@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Check If Facebook User Exists API
- (void)checkIfFacebookUserExists:(NSDictionary *)postDictionary
{
    self.mode = kCheckFacebookUser;
    NSString *endUrl = @"api/v1/clients/check_fb_user";
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    //NSLog(@"create user using fb: %@",postDictionary);
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

#pragma mark - Product API related Method

// Call Get Services Provided by Stylist API
-(void)getServices
{
    self.mode = kFetchServices;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/services/fetch_services?access_token=%@",stylistAC.accessToken];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"getServices: %@",urlString);
    
    [self requestDataInPath:urlString];
}

#pragma mark - Product API related Methods

// Call Add Product API
-(void)addProduct:(NSString *)ID cost:(NSString *)price
{
    self.mode = kAddProduct;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/products?access_token=%@",stylistAC.accessToken];
    
    NSMutableDictionary *postDictionary = [[NSMutableDictionary alloc]init];
    [postDictionary setObject:ID forKey:@"service_id"];
    [postDictionary setObject:price forKey:@"price"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"addProduct: %@",urlString);
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    [self postDataInPath:urlString withData:postData withContentType:@"application/json"];
}

// Call Delete Product API
-(void)deleteProduct:(NSString *)ID
{
    self.mode = kDeleteProduct;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/products/%@",ID];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,stylistAC.accessToken];
    //NSLog(@"deleteProduct: %@",urlString);
    
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.request setHTTPMethod:@"DELETE"];
    [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self connectionHandler:self.request];
}

- (void)clockInPartner
{
    self.mode = kPartnerClockIn;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partner/clock_in?access_token=%@",stylistAC.accessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"partner clock_in: %@",urlString);
    [self requestDataInPath:urlString];
}

-(void)partnerAvailability
{
    self.mode = kisPartnerAvailable;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partner/availability?access_token=%@",stylistAC.accessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"partner Availability: %@",urlString);
    [self requestDataInPath:urlString];
}

#pragma mark - Appoitment API related Methods

- (void)getAppointmentsCount
{
    self.mode = kPartnerAppointmentsCount;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partner/get_appointment_counts?access_token=%@",stylistAC.accessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"getPartnerAppointments Count: %@",urlString);
    [self requestDataInPath:urlString];
}

- (void)getPartnerAppointmentsListsFromDate:(NSString *)selectedDate
{
    self.mode = kPartnerAppointmentsList;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partners/%@/appointments/list_partner_appointments?date=%@&access_token=%@",stylistAC.userId,selectedDate,stylistAC.accessToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    //NSLog(@"getPartnerAppointmentsList: %@",urlString);
    [self requestDataInPath:urlString];
}

- (void)partnerConfirmAppointment:(NSDictionary *)postDictionary
{
    self.mode = kPartnerConfirmAppointment;
    
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"%@%@%@%@%@",@"api/v1/partners/",stylistAC.userId,@"/appointments/",[postDictionary valueForKey:@"appointment_id"],@"/partner_confirm_appointment"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,stylistAC.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

- (void)partnerCancelAppointment:(NSDictionary *)postDictionary
{
    self.mode = kPartnerCancelAppointment;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"%@%@%@%@%@",@"api/v1/partners/",stylistAC.userId,@"/appointments/",[postDictionary valueForKey:@"appointment_id"],@"/partner_cancel_appointment"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,stylistAC.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

#pragma mark - Appoitment API related Methods

-(void)getTimeSlotsForPartnerId:(NSString*)partnerId andForDate:(NSString *)selectedDate
{
    self.mode = kGetTimeSlots;
    UserAccount *userAccount = [UserAccount sharedInstance];
    NSString *endUrl = [NSString stringWithFormat:@"api/v1/partner/get_appointment_lists?appointment[partner_id]=%@&appointment[date]=%@&access_token=%@",partnerId,selectedDate,userAccount.accessToken];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"getTimeSlots: %@",urlString);
    
    [self requestDataInPath:encodedUrlString];
}

- (void)bookAppointment:(NSDictionary*)postDictionary
{
    self.mode = kBookAppointment;
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"%@%@%@",@"api/v1/clients/",userAccount.userId,@"/appointments/book_appointment"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

- (void)getAppointmentID:(NSDictionary*)postDictionary
{
    self.mode = kGetAppointmentID;
    UserAccount *userAccount = [UserAccount sharedInstance];
   
     NSString *endUrl = @"api/v1/client/get_single_appointment";
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kBaseUrl,endUrl];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

- (void)cancelUserAppointment:(NSDictionary*)postDictionary
{
    self.mode = kCancelUserAppointment;
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"%@%@%@%@%@",@"api/v1/clients/",userAccount.userId,@"/appointments/",[postDictionary valueForKey:@"appointment_id"],@"/client_cancel_appointment"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

- (void)sendStylist:(NSDictionary*)postDictionary
{
    self.mode = kSendStylist;
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    NSString *endUrl = [NSString stringWithFormat:@"%@%@",@"api/v1/client/appointment/send_now?partner_id=",[postDictionary valueForKey:@"partner_id"]];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary  options:1 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@&access_token=%@",kBaseUrl,endUrl,userAccount.accessToken];
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"Data: %@",postDictionary);
    [self postDataInPath:encodedUrlString withData:postData withContentType:@"application/json"];
}

@end
