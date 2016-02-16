//
//  Favourities+CoreDataProperties.h
//  ParlorMe
//

#import "Favourities.h"

NS_ASSUME_NONNULL_BEGIN

@interface Favourities (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *stylistId;
@property (nullable, nonatomic, retain) id stylistInfo;
@property (nullable, nonatomic, retain) id stylistList;
@property (nullable, nonatomic, retain) id selectedServices;
@property (nullable, nonatomic, retain) NSString *isFavourite;

@end

NS_ASSUME_NONNULL_END
