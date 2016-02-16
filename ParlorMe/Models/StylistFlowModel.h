//
//  StylistFlowModel.h
//  ParlorMe
//

#import <Foundation/Foundation.h>

@interface StylistFlowModel : NSObject
{
    StylistFlowModel *selectedStylist;
}

@property (nonatomic, copy) NSDictionary *stylistProfileData;
@property (nonatomic, strong) NSMutableDictionary *appointmentsList;
@property (nonatomic, strong) NSString *partnerAvailabilityString;
@property (nonatomic, strong) NSString *appointmentID;

+ (id)sharedInstance;
+ (void)removeSharedInstance;
@end
