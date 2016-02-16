//
//  Address+CoreDataProperties.h
//  ParlorMe
//
//  Created by sakshi on 15/10/15.
//  Copyright © 2015 dreamorbit. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Address.h"

NS_ASSUME_NONNULL_BEGIN

@interface Address (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *line1;
@property (nullable, nonatomic, retain) NSString *line2;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *zipcode;
@property (nullable, nonatomic, retain) User *currentUser;

@end

NS_ASSUME_NONNULL_END
