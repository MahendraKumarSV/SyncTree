//
//  Stylist+CoreDataProperties.h
//  ParlorMe
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Stylist.h"

NS_ASSUME_NONNULL_BEGIN

@interface Stylist (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) User *currentUser;

@end

NS_ASSUME_NONNULL_END
