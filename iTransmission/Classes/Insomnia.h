//
//  Insomnia.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 17/11/13.
//
//

#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>
#import <AVFoundation/AVFoundation.h>

#import "Controller.h"

@interface Insomnia : NSObject

- (BOOL)sleepMode;
- (void)disableSleep;
- (void)enableSleep;

@end
