//
//  StylistAccountParser.m
//  ParlorMe
//

#import "StylistAccountParser.h"
#import "StylistAccount.h"
#import "StylistDetails.h"
#import "StylistFlowModel.h"
#import "SingletonClass.h"
#import "Favourities+CoreDataProperties.h"
#import "CoreDataModel.h"

@implementation StylistAccountParser

#pragma mark - Parsing User Login/Registration related methods
//Parse Stylist Registration Response
-(NSString *)parseStylistRegistrationResponse:(id)response
{
    NSString *isRegistrationSuccessful;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    NSDictionary *errorMsg;
    
    if(responseData != nil)
    {
        NSDictionary *userData = [responseData objectForKey:@"partner"];
        NSString *accessToken = [userData objectForKey:@"access_token"];
        NSString *email = [userData objectForKey:@"email"];
        NSString *userId = [userData objectForKey:@"id"];
        NSString *mobilePhone = [userData objectForKey:@"mobile_phone"];
        errorMsg = [responseData objectForKey:@"errors"];
        
        stylistAC.userId = userId;
        stylistAC.mobilePhone = mobilePhone;
        stylistAC.accessToken = accessToken;
        stylistAC.email = email;
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
            isRegistrationSuccessful = @"Email or mobile number is already registered";
        }
    }
    else
    {
        isRegistrationSuccessful = @"Yes";
    }
    
    return  isRegistrationSuccessful;
}

//Parse Stylist Login Response
-(NSString *)parseStylistLoginResponse:(id)response
{
    NSString *isLoginSuccessful;
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];    
    NSDictionary *errorMsg = [[NSMutableDictionary alloc]init];
    
    if(responseData != nil)
    {
        NSDictionary *userData = [responseData objectForKey:@"partner"];
        NSString *accessToken = [userData objectForKey:@"access_token"];
        NSString *userId = [userData objectForKey:@"id"];
        errorMsg = [responseData objectForKey:@"errors"];
        
        stylistAC.userId = userId;
        stylistAC.accessToken = accessToken;
    }
    else
    {
        [errorMsg setValue:@"Invalid credentials" forKey:@"errors"];
    }
    
    if(errorMsg)
    {
        isLoginSuccessful = [errorMsg objectForKey:@"errors"];
        
        if([isLoginSuccessful rangeOfString:@"is already taken"].location != NSNotFound)
        {
            isLoginSuccessful = @"Email or mobile number is already registered";
        }
    }
    else
    {
        isLoginSuccessful = @"Yes";
    }
    
    return  isLoginSuccessful;
}

//Parse Stylist Forgot Password Response
-(NSString *)parseStylistForgotPasswordResponse:(id)response
{
    NSString *errorMsg, *isForgotPasswordSuccessful;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
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

#pragma mark - Parsing Stylist List Data method
//Parse Stylist List Response
-(NSString *)parseStylistList:(id)response
{
    NSString *errorMsg, *isParseStylistListSuccessful;
    NSArray *stylistList;
    NSMutableArray *stylistArray = [[NSMutableArray alloc]init];
    StylistDetails *stylistDetails = [StylistDetails sharedInstance];
    
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    stylistDetails.stylistResponseObj = [responseData objectForKey:@"partners"];
    //NSMutableArray *responseArr = [NSMutableArray arrayWithArray:stylistDetails.stylistList];
    [[SingletonClass shareManager]setStylistList:[responseData objectForKey:@"partners"]];//= [NSMutableArray arrayWithArray:stylistDetails.stylistList];
    //NSLog(@"[responseArray objectAtIndex:0]: %@",[[SingletonClass shareManager]stylistList]);
    
    NSArray *firstLoad = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"Favourities" andPredicate:[NSPredicate predicateWithFormat:@"stylistId==%@",@"response"] andSortDescriptor:nil forContext:nil];
    
    if([firstLoad count] > 0)
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
        [[CoreDataModel sharedCoreDataModel]saveContext];
    }
    
    /*NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:[responseData objectForKey:@"partners"] forKey:@"stylistsResponse"];
    [def synchronize];*/
    
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [responseData objectForKey:@"partners"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
    [defaults setObject:data forKey:@"stylistsResponse"];*/
    
    //NSLog(@"responseData: %@",stylistDetails.stylistResponseObj);
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
        stylistList = [responseData objectForKey:@"partners"];
        
        if(stylistList.count > 0)
        {
            for(int i = 0; i < stylistList.count; i++)
            {
                /*Favourities *favourities = (Favourities*)[[CoreDataModel sharedCoreDataModel] newEntityWithName:@"Favourities" forContext:nil];
                favourities.stylistId = [[stylistList objectAtIndex:i]objectForKey:@"id"];
                favourities.stylistInfo = [stylistList objectAtIndex:i];
                [[CoreDataModel sharedCoreDataModel]saveContext];*/
                
                StylistDetails *stylistInfoDetails = [[StylistDetails alloc]init];
                stylistInfoDetails.stylistName = [[stylistList objectAtIndex:i]objectForKey:@"name"];
                stylistInfoDetails.stylistId = [[stylistList objectAtIndex:i]objectForKey:@"id"];
                stylistInfoDetails.stylistExpereince = [[stylistList objectAtIndex:i]objectForKey:@"experience"];
                stylistInfoDetails.stylistBio = [[stylistList objectAtIndex:i]objectForKey:@"bio"];
                
                if(!stylistInfoDetails.stylistExpereince || [stylistInfoDetails.stylistExpereince isEqual:[NSNull null]])
                    stylistInfoDetails.stylistExpereince = @"0";
                
                stylistInfoDetails.stylistLocation = [[stylistList objectAtIndex:i]objectForKey:@"location"];
                stylistInfoDetails.stylistRatings = [[stylistList objectAtIndex:i]objectForKey:@"rating"];
                stylistInfoDetails.stylistFees = [[stylistList objectAtIndex:i]objectForKey:@"avg_price"];
                stylistInfoDetails.image = [[stylistList objectAtIndex:i]objectForKey:@"photo_url"];
                stylistInfoDetails.stylistPricingList= [[stylistList objectAtIndex:i] objectForKey:@"services"];
                
                if([stylistInfoDetails.stylistFees intValue] < 50)
                {
                    stylistInfoDetails.stylistFees = @"1";
                }
                else if([stylistInfoDetails.stylistFees intValue] >= 50 && [stylistInfoDetails.stylistFees intValue] < 100)
                {
                    stylistInfoDetails.stylistFees = @"2";
                }
                else
                {
                    stylistInfoDetails.stylistFees = @"3";
                }
                
                [stylistArray addObject:stylistInfoDetails];
            }
        }
    }
    else
    {
        errorMsg = @"Data not Found";
    }
    
    stylistDetails.stylistList = [NSMutableArray arrayWithArray:stylistArray];
    
    if(errorMsg)
    {
        isParseStylistListSuccessful = errorMsg;
    }
    else
    {
        isParseStylistListSuccessful = @"Yes";
    }
    
    return  isParseStylistListSuccessful;
}

#pragma mark - Parsing Stylist Schedule related methods
//Parse Stylist Set Schedule Response
-(NSString *)parseSetPartnerScheduleResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    //NSLog(@"responseData: %@",responseData);
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isSetPartnerSchedule = errorMsg;
    }
    else
    {
        self.isSetPartnerSchedule = @"SetPartnerSchedule";
    }
    
    return  self.isSetPartnerSchedule;
}

//Parse Stylist Update Schedule Response
-(NSString *)parseUpdatePartnerScheduleResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    //NSLog(@"responseData: %@",responseData);
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isUpdatePartnerSchedule = errorMsg;
    }
    
    else
    {
        self.isUpdatePartnerSchedule = @"UpdatePartnerSchedule";
    }
    
    return self.isUpdatePartnerSchedule;
}

//Parse Stylist Get Schedule Response
-(NSString *)parseGetPartnerScheduleResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isGetPartnerSchedule = errorMsg;
    }
    else
    {
        self.isGetPartnerSchedule = @"GetPartnerSchedule";
    }
    
    return  self.isGetPartnerSchedule;
}

#pragma mark - Parsing Stylist Profile related methods
//Parse Get Stylist Profile Response
-(NSString *)parseGetStylistProfileResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    [[StylistFlowModel sharedInstance] setStylistProfileData:responseData];
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isGetStylistProfileResponse = errorMsg;
    }
    else
    {
        self.isGetStylistProfileResponse = @"GetStylistProfile";
    }
    
    return self.isGetStylistProfileResponse;
}

//Parse Update Stylist Profile Response
-(NSString *)parseUpdateStylistProfileResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isUpdateStylistProfileResponse = errorMsg;
    }
    else
    {
        self.isUpdateStylistProfileResponse = @"Successfully updated";
    }
    
    return self.isUpdateStylistProfileResponse;
}

#pragma mark - Parsing Services List related method
//Parse Get Categories/Services Response
-(NSString *)parseGetCategoriesResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"error"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isGetCategoriesResponse = errorMsg;
    }
    else
    {
        self.isGetCategoriesResponse = @"FetchServices";
    }
    
    return self.isGetCategoriesResponse;
}

#pragma mark - Parsing Product API related methods

//Parse Add Product Response
-(NSString *)parseAddProductResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        errorMsg = [[responseData objectForKey:@"errors"] valueForKey:@"service_id"];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isNewProductAdded = @"already exists";
    }
    else
    {
        self.isNewProductAdded = @"NewProductAdded";
    }
    
    return self.isNewProductAdded;
}

//Parse Delete Product Response
-(NSString *)parseDeleteProductResponse:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    if(responseData != nil)
    {
        errorMsg = [[responseData objectForKey:@"errors"] valueForKey:@"service_id"];
    }
    
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isProductDeleted = @"already exists";
    }
    
    else
    {
        self.isProductDeleted = @"ProdutDeleted";
    }
    
    return self.isProductDeleted;
}

-(NSString *)parsePartnerAppointmentsCount:(id)response
{
    NSString *errorMsg;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    //NSLog(@"parsePartnerAppointmentsCount: %@",response);
    
    if(responseData != nil)
    {
        errorMsg = [responseData objectForKey:@"errors"];
    }
    
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        self.isPartnerAppointmentsCount = errorMsg;
    }
    
    else
    {
        self.isPartnerAppointmentsCount = @"CountExists";
    }
    
    return self.isPartnerAppointmentsCount;
}

-(NSString *)parsePartnerClockIn:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    //NSLog(@"clockin responseData; %@",responseData);
    
    self.isPartnerClockIn = [responseData objectForKey:@"available"];
    
    return self.isPartnerClockIn;
}

-(NSString *)parsePartnerAvailability:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    //NSLog(@"available responseData: %@",responseData);
    
    self.isPartnerAvailable = [responseData objectForKey:@"available"];
    
    return self.isPartnerAvailable;
}

-(NSString *)parsePartnerAppointmentsList:(id)response
{
    NSMutableDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:Nil];
    
    [[StylistFlowModel sharedInstance] setAppointmentsList:responseData];
    
    //self.isPartnerAppiontmentsListResponse = [[responseData objectForKey:@"available"] objectAtIndex:0];
    
    return self.isPartnerAppiontmentsListResponse;
}

-(NSString *)parsePartnerConfirmAppointment:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    //NSLog(@"responseData: %@",responseData);
    
    self.isPartnerClockIn = [responseData objectForKey:@"appointment_state"];
    
    return self.isPartnerConfirmAppointment;
}

-(NSString *)parsePartnerCancelAppointment:(id)response
{
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    //NSLog(@"responseData: %@",responseData);
    
    self.isPartnerClockIn = [responseData objectForKey:@"appointment_state"];
    
    return self.isPartnerCancelAppointment;
}

#pragma mark - Parsing Stylist Appointment Slots related method

//Parse Get Time Slots Response
-(NSString *)parseGetTimeSlotsResponse:(id)response
{
    NSString *errorMsg;
    NSString *isParseTimeSlotResponseSuccessfull;
    NSDictionary *availableSlots;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:0 error:Nil];
    
    StylistDetails *stylistDetailsObj = [StylistDetails sharedInstance];
    
    if(responseData != nil)
    {
        NSMutableArray *availableTimeSlots = [[NSMutableArray alloc]init];
        NSMutableArray *bookedTimeSlots = [[NSMutableArray alloc]init];
        NSMutableArray *bookedTimeSlotList = [[NSMutableArray alloc]init];
        
        errorMsg = [responseData objectForKey:@"errors"];
        availableSlots = [responseData objectForKey:@"appointment_details"];
        
        if(!availableSlots)
            errorMsg = [responseData objectForKey:@"message"];
        
        NSString *fromTime = [availableSlots objectForKey:@"from_time"];
        NSString *toTime = [availableSlots objectForKey:@"to_time"];      
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"hh:mma"];
        
        NSDate *startTimeDate = [formatter dateFromString:fromTime];
        NSDate *endTimeDate = [formatter dateFromString:toTime];
        
        int startTime  = [self minutesSinceMidnight:startTimeDate];
        int endTime = [self minutesSinceMidnight:endTimeDate];
        
        [availableTimeSlots removeAllObjects];
        
        while (startTime < endTime)
        {
            NSString *timeString = [[formatter stringFromDate:startTimeDate]lowercaseString];
            [availableTimeSlots addObject:timeString];
            
            NSDate *newDate = [startTimeDate dateByAddingTimeInterval:60*60];
            startTimeDate = newDate;
            startTime = [self minutesSinceMidnight:newDate];
        }
        
        //NSLog(@"%@",availableTimeSlots);
        
        stylistDetailsObj.availableTimeSlots = [NSMutableArray arrayWithArray:availableTimeSlots];
        
        bookedTimeSlots = [availableSlots objectForKey:@"booked_slots"];
        
        [bookedTimeSlotList removeAllObjects];
        
        for(NSDictionary *bookedSlotDict in bookedTimeSlots)
        {
            //NSLog(@"Booked Slot %@", [bookedSlotDict valueForKey:@"booked_slots"]);
            [bookedTimeSlotList addObject:[[[bookedSlotDict valueForKey:@"booked_slots"] stringByReplacingOccurrencesOfString:@" " withString:@""]lowercaseString]];
        }
        
        stylistDetailsObj.bookedTimeSlots = [NSMutableArray arrayWithArray:bookedTimeSlotList];
    }
    else
    {
        errorMsg = @"Invalid response";
    }
    
    if(errorMsg)
    {
        isParseTimeSlotResponseSuccessfull= errorMsg;
        stylistDetailsObj.availableTimeSlots = nil;
        stylistDetailsObj.bookedTimeSlots = nil;
    }
    else
    {
        isParseTimeSlotResponseSuccessfull = @"Yes";
    }
    
    return isParseTimeSlotResponseSuccessfull;
}

-(int)minutesSinceMidnight:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    return 60 * (int)[components hour] + (int)[components minute];
}

@end
