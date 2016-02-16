//
//  User.h
//  ParlorMe
//
//  Created by ratheesh.shivraman on 14/01/16.
//  Copyright © 2016 dreamorbit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, MainCategories, Services, Stylist;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
