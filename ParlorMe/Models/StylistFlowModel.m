//
//  StylistFlowModel.m
//  ParlorMe
//

#import "StylistFlowModel.h"

@implementation StylistFlowModel
@synthesize stylistProfileData;

static StylistFlowModel *shared = nil;

+ (id)sharedInstance
{
    if(shared == nil)
        shared = [[StylistFlowModel alloc]init] ;
    
    return shared;
}

+ (void)removeSharedInstance {
    shared = nil;
}

- (id)init
{
    return self;
}

@end
