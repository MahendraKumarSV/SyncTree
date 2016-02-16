//
//  ClockInAndOut+CoreDataProperties.h
//  ParlorMe
//
//  Created by sakshi on 21/10/15.
//  Copyright © 2015 dreamorbit. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClockInAndOut.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClockInAndOut (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *status;

@end

NS_ASSUME_NONNULL_END
