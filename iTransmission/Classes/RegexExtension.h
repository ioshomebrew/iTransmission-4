//
//  RegexExtension.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (RegexExtension)
- (BOOL)isURL;
- (BOOL)isMagnet;
@end
