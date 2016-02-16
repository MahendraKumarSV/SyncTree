//
//  Services+CoreDataProperties.h
//  ParlorMe
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Services.h"

NS_ASSUME_NONNULL_BEGIN

@interface Services (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *categoryName;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *price;
@property (nullable, nonatomic, retain) NSString *productId;
@property (nullable, nonatomic, retain) User *currentUser;

@end

NS_ASSUME_NONNULL_END
