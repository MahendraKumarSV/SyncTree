//
//  User+CoreDataProperties.h
//  ParlorMe
//
//  Created by ratheesh.shivraman on 14/01/16.
//  Copyright © 2016 dreamorbit. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *appointmentID;
@property (nullable, nonatomic, retain) NSString *dob;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *isAddressSelected;
@property (nullable, nonatomic, retain) NSString *isCreditCardSelected;
@property (nullable, nonatomic, retain) NSString *isPaymentDone;
@property (nullable, nonatomic, retain) NSString *isServicesSelected;
@property (nullable, nonatomic, retain) NSString *isStlistSelected;
@property (nullable, nonatomic, retain) NSString *mobile;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *selectedAddressId;
@property (nullable, nonatomic, retain) NSString *selectedAddressTag;
@property (nullable, nonatomic, retain) NSString *selectedCreditCardTag;
@property (nullable, nonatomic, retain) NSString *selectedDate;
@property (nullable, nonatomic, retain) NSString *selectedStylistName;
@property (nullable, nonatomic, retain) NSString *selectedStylistTag;
@property (nullable, nonatomic, retain) NSString *selectedTime;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *accessToken;
@property (nullable, nonatomic, retain) NSNumber *isUserTypeClient;
@property (nullable, nonatomic, retain) NSSet<MainCategories *> *selectedCategories;
@property (nullable, nonatomic, retain) NSSet<Services *> *selectedServices;
@property (nullable, nonatomic, retain) Stylist *selectedStylist;
@property (nullable, nonatomic, retain) Address *slectedAddress;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addSelectedCategoriesObject:(MainCategories *)value;
- (void)removeSelectedCategoriesObject:(MainCategories *)value;
- (void)addSelectedCategories:(NSSet<MainCategories *> *)values;
- (void)removeSelectedCategories:(NSSet<MainCategories *> *)values;

- (void)addSelectedServicesObject:(Services *)value;
- (void)removeSelectedServicesObject:(Services *)value;
- (void)addSelectedServices:(NSSet<Services *> *)values;
- (void)removeSelectedServices:(NSSet<Services *> *)values;

@end

NS_ASSUME_NONNULL_END
