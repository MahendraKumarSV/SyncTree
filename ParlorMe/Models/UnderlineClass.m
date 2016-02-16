//
//  UnderlineClass.m
//  ParlorMe
//
//  Created by ratheesh.shivraman on 22/12/15.
//  Copyright © 2015 dreamorbit. All rights reserved.
//

#import "UnderlineClass.h"

@implementation UnderlineClass

- (void)drawRect:(CGRect)rect
{
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, [UIColor grayColor].CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender + 2.0);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender + 2);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
    
}

@end
