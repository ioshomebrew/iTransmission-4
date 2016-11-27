//
//  GADMAdapterAdColonyExtras.h
//  AdColonyAdapter
//
//  Created by AdColony on 11/18/13.
//
//

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GADMAdapterAdColonyExtras : NSObject <GADAdNetworkExtras>

@property (nonatomic, retain) NSString *currentZone;

- (id)initWithZone:(NSString *)zoneID;

@end
