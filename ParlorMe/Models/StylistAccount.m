//
//  StylistAccount.m
//  ParlorMe
//

#import "StylistAccount.h"

@implementation StylistAccount

static StylistAccount *shared = nil;

+ (id)sharedInstance
{
    if(shared == nil)
        shared = [[StylistAccount alloc]init] ;
    
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
