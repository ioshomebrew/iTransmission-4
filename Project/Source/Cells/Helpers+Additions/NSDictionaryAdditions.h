//
//  NSDictionaryAdditions.h
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (iTransmission)
- (BOOL)boolForKey:(NSString*)key;
- (NSString*)stringForKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key;

@end

@interface NSMutableDictionary (iTransmission)
- (void)setBool:(BOOL)v forKey:(NSString*)key;
- (void)setString:(NSString*)s forKey:(NSString*)key;
- (void)setInteger:(NSInteger)i forKey:(NSString*)key;

@end