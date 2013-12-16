//
//  RegexExtension.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RegexExtension.h"
#import "RegexKitLite.h"

@implementation NSString (RegexExtension)

- (BOOL)isURL
{
    NSString *lowCased = [self lowercaseString];
    if (![lowCased hasPrefix:@"http://"] && ![lowCased hasPrefix:@"https://"] && ![lowCased hasPrefix:@"ftp://"])
        return NO;
    NSString *urlEx = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"url_ex" ofType:@""]  encoding:NSASCIIStringEncoding error:nil];
    NSString *match = [self stringByMatching:urlEx];
    return ([match isEqualToString:self]);
}

- (BOOL)isMagnet
{
    NSString *magnetEx = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnet_ex" ofType:@""]  encoding:NSASCIIStringEncoding error:nil];
    NSString *match = [self stringByMatching:magnetEx];
    return ([match isEqualToString:self]);}

@end
