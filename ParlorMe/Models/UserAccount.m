//
//  UserAccount.m
//  ParlorMe
//

#import "UserAccount.h"

@implementation UserAccount

static UserAccount *shared = nil;
+ (id)sharedInstance
{
    if(shared == nil)
        shared = [[UserAccount alloc]init] ;
    
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
