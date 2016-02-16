//
//  StylistDetails.m
//  ParlorMe
//

#import "StylistDetails.h"

@implementation StylistDetails
@synthesize selectedStylist;

static StylistDetails *shared = nil;

+ (id)sharedInstance
{
    if(shared == nil)
        shared = [[StylistDetails alloc]init];
    
    return shared;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:value forKey:@"Value"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    value = [decoder decodeObjectForKey:@"Value"];
    return self;
}

- (id)init
{
    return self;
}

@end
