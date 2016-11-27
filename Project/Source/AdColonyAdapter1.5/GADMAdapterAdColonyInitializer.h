//
//  GADMAdapterAdColonyInitializer.h
//  AdColonyAdapter
//
//  Created by AdColony on 3/10/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface GADMAdapterAdColonyInitializer : NSObject

+ (void)startWithAppID:(NSString *)appID andZones:(NSArray *)zones andCustomID:(NSString* __nullable )customID;

@end
NS_ASSUME_NONNULL_END
