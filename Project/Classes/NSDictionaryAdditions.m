//
//  NSDictionaryAdditions.m
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDictionaryAdditions.h"


@implementation NSDictionary (iTransmission)

- (BOOL)boolForKey:(NSString *)key
{
	return [(NSNumber*)[self objectForKey:key] boolValue];
}

- (NSString*)stringForKey:(NSString*)key
{
	return (NSString*)[self objectForKey:key];
}

- (NSInteger)integerForKey:(NSString*)key
{
	return [(NSNumber*)[self objectForKey:key] intValue];
}

@end

@implementation NSMutableDictionary (iTransmission)

- (void)setBool:(BOOL)v forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithBool:v] forKey:key];
}

- (void)setString:(NSString*)s forKey:(NSString*)key
{
	[self setObject:s forKey:key];
}

- (void)setInteger:(NSInteger)i forKey:(NSString*)key
{
	[self setObject:[NSNumber numberWithInt:i] forKey:key];
}

@end