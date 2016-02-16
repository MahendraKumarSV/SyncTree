
//  NSURLRequest+IgnoreSSL.m
//  ParlorMe

#import "NSURLRequest+IgnoreSSL.h"

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    // ignore certificate errors only for this domain
    if ([host hasSuffix:@"facebook.com"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
