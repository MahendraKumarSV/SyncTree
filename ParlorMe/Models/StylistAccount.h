//
//  StylistAccount.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface StylistAccount : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobilePhone;
@property (nonatomic, strong) NSDictionary *stylistAppointmentNotificationDictionary;
@property (nonatomic, strong) NSMutableArray *stylistAppointmentDatesArray;
@property (nonatomic, strong) NSMutableArray *stylistAppointmentCountArray;

+ (id)sharedInstance;
+ (void)removeSharedInstance;
@end
