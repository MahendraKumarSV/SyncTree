
//  NSURLRequest+IgnoreSSL.h
//  ParlorMe

#import <Foundation/Foundation.h>

@interface NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

@end
