//
//  StylistDetails.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface StylistDetails : NSObject
{
    StylistDetails *selectedStylist;
    NSString *value;
}

@property (nonatomic, copy) NSString *stylistId;
@property (nonatomic, copy) NSString *stylistRatings;
@property (nonatomic, copy) NSString *stylistName;
@property (nonatomic, copy) NSString *stylistFees;
@property (nonatomic, copy) NSString *stylistExpereince;
@property (nonatomic, copy) NSString *stylistBio;
@property (nonatomic, copy) NSString *stylistLocation;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSArray  *stylistList;
@property (nonatomic, copy) NSMutableArray *stylistResponseObj;
@property (nonatomic, copy) NSArray *stylistPricingList;
@property (nonatomic, copy) NSDictionary *stylistServicePriceDict;
@property (nonatomic, copy) NSDictionary *stylistCategoryPriceDict;
@property (nonatomic, copy) NSDictionary *productIdDict;
@property (nonatomic, copy) NSMutableArray *availableTimeSlots;
@property (nonatomic, copy) NSMutableArray *bookedTimeSlots;
@property (nonatomic, retain) StylistDetails *selectedStylist;

+ (id)sharedInstance;

@end
