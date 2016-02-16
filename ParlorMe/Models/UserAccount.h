//
//  UserAccount.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, assign) BOOL isUserTypeClient;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobilePhone;
@property (nonatomic, copy) NSString *resetToken;
@property (nonatomic, copy) NSArray *categoryList;
@property (nonatomic, copy) NSArray *subCategoryList;
@property (nonatomic, copy) NSDictionary *selectedServicesList;
@property (nonatomic, copy) NSArray *selectedsubCategoryList;
@property (nonatomic, copy) NSArray *cateroryImages;
@property (nonatomic, copy) NSArray *userAddressList;
@property (nonatomic, copy) NSArray *selectedUserAddress;
@property (nonatomic, copy) NSString *clientToken;
@property (nonatomic, copy) NSArray *userCreditCardList;
@property (nonatomic, copy) NSString *selectedAddressId;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *selectedStylistName;
@property (nonatomic, copy) NSString *appointmentId;
@property (nonatomic, copy) NSString *fromTime;
@property (nonatomic, copy) NSString *selectedDate;
@property (nonatomic, copy) NSString *userLocationPincode;
@property (nonatomic, copy) NSString *deviceToken;

+ (id)sharedInstance;
+ (void)removeSharedInstance;
@end
