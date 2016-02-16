//
//  UserAccountParser.m
//  ParlorMe
//

#import "UserAccountParser.h"
#import "UserAccount.h"

@implementation UserAccountParser

#pragma mark - Parsing User Login/Registration related methods
//Parse User Registration Response
-(NSString *)parseRegistrationResponse:(id)response
{
    NSString *isRegistrationSuccessful;
    
    UserAccount *userAC = [UserAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *userData;
    NSDictionary *errorMsg;
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"errors"];
    }
    else
    {
        [errorMsg setValue:@"Invalid credentials" forKey:@"errors"];
    }
    
    if(errorMsg)
    {
        isRegistrationSuccessful = [errorMsg objectForKey:@"errors"];
        
        if([isRegistrationSuccessful rangeOfString:@"is already taken"].location != NSNotFound)
        {
           // userAC.userId = @"Guest";
            isRegistrationSuccessful = @"Email or mobile number is already registered";
        }
    }
    else
    {
        userData = [responseData objectForKey:@"client"];
        userAC.accessToken = [userData objectForKey:@"access_token"];
        userAC.isUserTypeClient = YES;
        userAC.email = [userData objectForKey:@"email"];
        userAC.userId = [userData objectForKey:@"id"];
        userAC.mobilePhone = [userData objectForKey:@"mobile_phone"];
        userAC.userName = [userData objectForKey:@"name"];
        
        isRegistrationSuccessful = @"Yes";
    }
    
    return  isRegistrationSuccessful;
}

//Parse User Login Response
-(NSString *)parseLoginResponse:(id)response
{
    NSString *isLoginSuccessful;
    
    UserAccount *userAC = [UserAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg = [[NSMutableDictionary alloc]init];
    
    if(responseData != nil)
    {
        NSDictionary *userData = [responseData objectForKey:@"client"];
        NSString *accessToken = [userData objectForKey:@"access_token"];
        NSString *userId = [userData objectForKey:@"id"];
        errorMsg = [responseData objectForKey:@"errors"];
        userAC.userId = userId;
        userAC.accessToken = accessToken;
        userAC.isUserTypeClient = YES;
        userAC.userName = [userData objectForKey:@"name"];
    }
    else
    {
        [errorMsg setValue:@"Invalid credentials" forKey:@"errors"];
    }
    
    if(errorMsg)
    {
        NSString *error = [errorMsg objectForKey:@"errors"];
        isLoginSuccessful = error;
        
        if([error rangeOfString:@"is already taken"].location != NSNotFound)
        {
            isLoginSuccessful = @"Email or mobile number is already registered";
        }
        else
        {
            isLoginSuccessful = error;
        }
    }
    else
    {
        isLoginSuccessful = @"Yes";
    }
    
    return  isLoginSuccessful;
}

//Parse User Forgot Password Response
-(NSString *)parseForgotPasswordResponse:(id)response
{
    NSString *isForgotPasswordSuccessful;
    UserAccount *userAC = [UserAccount sharedInstance];
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        NSString *accessToken = [responseData objectForKey:@"reset_password_token"];
        userAC.resetToken = accessToken;
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid mail id";
    }
    
    if(errorMsg)
    {
        isForgotPasswordSuccessful = errorMsg;
    }
    else
    {
        isForgotPasswordSuccessful = @"Yes";
    }
    
    return  isForgotPasswordSuccessful;
}

//Parse User Management Response
-(NSString *)parseUserMgmtResponse:(id)response
{
    UserAccount *userAC = [UserAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg;
    
    if(responseData != nil)
    {
        
        NSDictionary *userData = [responseData objectForKey:@"user"];
        NSString *email = [userData objectForKey:@"email"];
        errorMsg = [responseData objectForKey:@"errors"];
        userAC.email = email;
    }
    else
    {
        [errorMsg setValue:@"Invalid credentials" forKey:@"errors"];
    }
    
    if(errorMsg)
    {
        NSString *error = [errorMsg objectForKey:@"errors"];
        self.isUserMgmtSuccessful = error;
        if([error rangeOfString:@"is already taken"].location != NSNotFound)
        {
            self.isUserMgmtSuccessful = @"Email or mobile number is already registered";
        }
        else
        {
            self.isUserMgmtSuccessful = error;
        }
    }
    else
    {
        self.isUserMgmtSuccessful = @"Yes";
    }
    
    return  self.isUserMgmtSuccessful;
}

//Parse User Reset Password Response
-(NSString *)parseResetPasswordResponse:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    if(errorMsg)
    {
        self.isResetPasswordSuccessful = errorMsg;
    }
    else
    {
        self.isResetPasswordSuccessful = @"Yes";
    }
    
    return  self.isResetPasswordSuccessful;
}

#pragma mark - Parsing Category API related methods
//Parse Get Category Response
-(NSString *)parseCategoryResponse:(id)response
{
    NSString* isParseCategoryResponseSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    NSString *errorMsg;
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
        NSDictionary *categoryNameList = [responseData objectForKey:@"categories"];
        NSArray *categoryList = [categoryNameList valueForKey:@"name"];
        NSArray *imageArray = [categoryNameList valueForKey:@"category_image"];
        NSDictionary *subCategoryDict = [categoryNameList valueForKey:@"services"];
        NSArray *subCategoryList = [subCategoryDict valueForKey:@"name"];
        
        UserAccount *userAC = [UserAccount sharedInstance];
        userAC.categoryList = categoryList;
        userAC.subCategoryList = subCategoryList;
        userAC.cateroryImages = imageArray;
    }
    else
    {
        errorMsg = @"Data not available";
    }
    
    if(errorMsg)
    {
        isParseCategoryResponseSuccessful = errorMsg;
    }
    else
    {
        isParseCategoryResponseSuccessful = @"Yes";
    }
    
    return isParseCategoryResponseSuccessful;
}

#pragma mark - Parsing Address API related methods

//Parse Get Address Using GPS Response
-(NSString *)parseGetAddressUsingGPSresponse:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *checkIfAddressAvailable;
    NSDictionary *errorMsg = [[NSMutableDictionary alloc]init];
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"errors"];
        //NSArray *addressList = [responseData objectForKey:@"results"];
        //NSLog(@"%@",[[addressList objectAtIndex:0]objectForKey:@"formatted_address"]);
        //NSLog(@"%@",[[addressList objectAtIndex:0]objectForKey:@"address_components"]);
        
       // NSDictionary *addressDict = [[addressList objectAtIndex:0]objectForKey:@"address_components"];
        
        //NSLog(@"%@", addressDict valueForKey:@"");
        
        //NSLog(@"%@",[addressDict objectForKey:@"address_components"]);
    }
    else
    {
        [errorMsg setValue:@"UserNotRegistered" forKey:@"errors"];
    }
    
    if(errorMsg )
    {
        // NSString *error = [errorMsg objectForKey:@"user"];
        checkIfAddressAvailable = @"UserNotRegistered";
    }
    else
    {
        checkIfAddressAvailable = @"Yes";
    }
    
    return checkIfAddressAvailable;
}

//Parse Get Address List Response
-(NSString *)parseGetAddressListResponse:(id)response
{
    NSString *isParseAddressResponseSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    NSArray *addressList = [responseData valueForKey:@"addresses"];
    
    UserAccount *userAC = [UserAccount sharedInstance];
    userAC.userAddressList = addressList;
    
    if(errorMsg)
    {
        isParseAddressResponseSuccessful = errorMsg;
    }
    else
    {
        isParseAddressResponseSuccessful = @"Yes";
    }
    
    return isParseAddressResponseSuccessful;
}

//Parse Save Address Response
-(NSString *)parseSaveAddressResponse:(id)response
{
    NSString *isParseSaveAddressSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    
    if(errorMsg)
    {
        isParseSaveAddressSuccessful = errorMsg;
    }
    else
    {
        isParseSaveAddressSuccessful = @"Yes";
    }
    
    return isParseSaveAddressSuccessful;
}

#pragma mark - Parsing Payment related methods

//Parse Get Client Token Response
-(NSString *)parseGetClientTokenResponse:(id)response
{
    NSString *isClientTokenRecieved;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    
    UserAccount *userAC = [UserAccount sharedInstance];
    userAC.clientToken = [responseData objectForKey:@"braintree_client_token"];
    
    if(errorMsg)
    {
        isClientTokenRecieved = errorMsg;
    }
    else
    {
        isClientTokenRecieved = @"Yes";
    }
    
    return isClientTokenRecieved;
}

//Parse Get Credit Card List Response
-(NSString *)parseGetCreditCardListResponse:(id)response
{
    NSString *isParseGetCreditCardListResponseSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    NSArray *cardList = [responseData valueForKey:@"card_details"];
    
    UserAccount *userAC = [UserAccount sharedInstance];
    userAC.userCreditCardList = cardList;
    
    if(errorMsg)
    {
        isParseGetCreditCardListResponseSuccessful = errorMsg;
    }
    else
    {
        isParseGetCreditCardListResponseSuccessful = @"Yes";
    }
    
    return isParseGetCreditCardListResponseSuccessful;
}

//Parse Save Credit Card Response
-(NSString *)parseSaveCreditCardResponse:(id)response
{
    NSString *isParseSaveCreditCardSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg = [responseData objectForKey:@"errors"];
    
    if(errorMsg)
    {
        isParseSaveCreditCardSuccessful = [[errorMsg valueForKey:@"message"]objectAtIndex:0];
    }
    else
    {
        isParseSaveCreditCardSuccessful = @"Yes";
    }
    
    return isParseSaveCreditCardSuccessful;
}

//Parse Make Payment Response
-(NSString *)parseMakePaymentResponse:(id)response
{
    NSString *isPaymentSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    NSString *status = [responseData objectForKey:@"status"];
    
    if((errorMsg) || [status isEqualToString:@"Something went wrong please try again"])
    {
        isPaymentSuccessful = @"Unable to make payment";
    }
    else
    {
        isPaymentSuccessful = @"Yes";
    }
    
    return isPaymentSuccessful;
}

#pragma mark - Parsing User Profile Details related methods

//Parse Get User Details Response
-(NSString *)parseGetUserDetailsResponse:(id)response
{
    NSString *isParseGetUserDetailsSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    NSDictionary *userDetailsDict = [responseData valueForKey:@"client"];
    
    UserAccount *userAC = [UserAccount sharedInstance];
    userAC.email = [userDetailsDict valueForKey:@"email"];
    userAC.mobilePhone = [userDetailsDict valueForKey:@"phone"];
    userAC.birthday = [userDetailsDict valueForKey:@"birthday"];
    userAC.userName = [userDetailsDict valueForKey:@"name"];
    
    if(errorMsg)
    {
        isParseGetUserDetailsSuccessful = errorMsg;
    }
    else
    {
        isParseGetUserDetailsSuccessful = @"Yes";
    }
    
    return isParseGetUserDetailsSuccessful;
}

//Parse Save User Details Response
-(NSString *)parseSaveUserDetailsResponse:(id)response
{
    NSString *isParseSaveUserDetailsSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSString *errorMsg = [responseData objectForKey:@"error"];
    NSString *status = [responseData objectForKey:@"status"];
    
    if((errorMsg) || [status isEqualToString:@"Something went wrong please try again"])
    {
        isParseSaveUserDetailsSuccessful = @"Unable to save user details";
    }
    else
    {
        isParseSaveUserDetailsSuccessful = @"Yes";
    }
    
    return isParseSaveUserDetailsSuccessful;
}

#pragma mark - Parsing Facebook API related methods

//Parse Create Facebook User Response
-(NSString *)parseCreateUserUsingFacebookResponse:(id)response
{
    NSString *isCreateUserUsingFacebookSuccessful;
    
    UserAccount *userAC = [UserAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg = [[NSMutableDictionary alloc]init];
    NSString *accessToken,*userId;
    NSDictionary *userData;
    
    if(responseData != nil)
    {
        userData = [responseData objectForKey:@"client"];
        accessToken = [userData objectForKey:@"access_token"];
        userId = [userData objectForKey:@"id"];
        errorMsg = [responseData objectForKey:@"errors"];
        
    }
    else
    {
        [errorMsg setValue:@"Invalid credentials" forKey:@"errors"];
    }
    
    if(errorMsg )
    {
        NSString *error = [errorMsg objectForKey:@"errors"];
        isCreateUserUsingFacebookSuccessful = error;
        
        if([error rangeOfString:@"is already taken"].location != NSNotFound)
        {
            isCreateUserUsingFacebookSuccessful = @"Email or mobile number is already registered";
        }
        else
        {
            isCreateUserUsingFacebookSuccessful = error;
        }
    }
    else
    {
        userAC.userId = userId;
        userAC.accessToken = accessToken;
        userAC.userName = [userData objectForKey:@"name"];
        
        isCreateUserUsingFacebookSuccessful = @"Yes";
    }
    
    return  isCreateUserUsingFacebookSuccessful;
}

//Parse Check If Facebook User Exists Response
-(NSString *)checkIfFacebookUser:(id)response
{
    NSString *checkIfFacebookUser;
    
    UserAccount *userAC = [UserAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg = [[NSMutableDictionary alloc]init];
    NSString *accessToken,*userId;
    NSDictionary *userData;
    
    if(responseData != nil)
    {
        userData = [responseData objectForKey:@"client"];
        accessToken = [userData objectForKey:@"access_token"];
        userId = [userData objectForKey:@"id"];
        errorMsg = [responseData objectForKey:@"errors"];
    }
    else
    {
        [errorMsg setValue:@"UserNotRegistered" forKey:@"errors"];
    }
    
    if(errorMsg )
    {
        checkIfFacebookUser = @"UserNotRegistered";
    }
    else
    {
        userAC.userId = userId;
        userAC.accessToken = accessToken;
        userAC.userName = [userData objectForKey:@"name"];
        userAC.email = [userData objectForKey:@"email"];
        checkIfFacebookUser = @"IsAFacebookUser";
    }
    
    return  checkIfFacebookUser;
}

//Parse Book Appointment Response
-(NSString *)parseBookAppointmentResponse:(id)response
{
    NSString *errorMsg;
    NSString *isParseBookAppointmentResponseSuccessfull;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(responseData != nil)
    {
        errorMsg = [[responseData objectForKey:@"errors"]objectAtIndex:0];
        NSDictionary *appointment = [responseData objectForKey:@"appointment"];
        
        if(appointment)
            userAccount.appointmentId = [appointment objectForKey:@"appointment_id"];
        
        NSString *slotAlreadyBooked = [[responseData objectForKey:@"from_time"]objectAtIndex:0];
        
        if(slotAlreadyBooked)
            userAccount.appointmentId = nil;
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        isParseBookAppointmentResponseSuccessfull = errorMsg;
    }
    else
    {
        isParseBookAppointmentResponseSuccessfull = @"Yes";
    }
    
    return isParseBookAppointmentResponseSuccessfull;
}

//Parse Get Appointment Id Response
-(NSString *)parseGetAppointmentIDResponse:(id)response
{
    NSString *errorMsg;
    NSString *isParseGetAppointmentIDResponseSuccessfull;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(responseData != nil)
    {
        errorMsg = [[responseData objectForKey:@"errors"]objectAtIndex:0];
        NSDictionary *appointment = [responseData objectForKey:@"appointment_details"];
        
        userAccount.appointmentId = [appointment objectForKey:@"appointment_id"];
        
        if(!userAccount.appointmentId)
            errorMsg = @"Invalid response";
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        isParseGetAppointmentIDResponseSuccessfull = errorMsg;
    }
    else
    {
        isParseGetAppointmentIDResponseSuccessfull = @"Yes";
    }
    
    return isParseGetAppointmentIDResponseSuccessfull;
}

//Parse Cancel Appointment API Response
-(NSString *)parseCancelAppointmentAPIResponse:(id)response
{
    NSString *errorMsg;
    NSString *isCancelAppointmentResponseSuccessfull;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];

    if(responseData != nil)
    {
        errorMsg = [[responseData objectForKey:@"errors"]objectAtIndex:0];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        isCancelAppointmentResponseSuccessfull = errorMsg;
    }
    else
    {
        isCancelAppointmentResponseSuccessfull = @"Yes";
    }
    
    return isCancelAppointmentResponseSuccessfull;
}


//Parse Send Stylist Response
-(NSString *)parseSendStylistNowResponse:(id)response
{
    NSString *errorMsg;
    NSString *isParseSendStylistResponseSuccessfull;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    UserAccount *userAccount = [UserAccount sharedInstance];
    
    if(responseData != nil)
    {
        NSDictionary *appointment = [responseData objectForKey:@"appointment"];
        
        if(appointment)
            userAccount.appointmentId = [appointment objectForKey:@"appointment_id"];
        else
           errorMsg = [[responseData objectForKey:@"errors"]objectAtIndex:0];
    }
    else
    {
        errorMsg = @"Invalid Response";
    }
    
    if(errorMsg)
    {
        isParseSendStylistResponseSuccessfull = errorMsg;
    }
    else
    {
        NSDate *currentDate = [NSDate date];
        NSDate *newDate = [currentDate dateByAddingTimeInterval:60*30];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"hh:mma"];
        userAccount.fromTime = [formatter stringFromDate:newDate];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        userAccount.selectedDate = [formatter stringFromDate:newDate];
        
        isParseSendStylistResponseSuccessfull = @"Yes";
    }
    
    return isParseSendStylistResponseSuccessfull;
}

@end
