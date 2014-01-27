//
//  Insomnia.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 17/11/13.
//
//

#import "Insomnia.h"

@interface Insomnia() {
    BOOL mode;
    IONotificationPortRef notificationPort;
    io_connect_t root_port;
    io_object_t notifier;
	IOPMAssertionID assertionID;
	NSTimer *preventSleepWithAudioTimer;
	NSTimer *preventSleepWithAssertionTimer;
}

- (BOOL)isInSandbox;

- (void)powerMessageReceived:(natural_t)messageType withArgument:(void *) messageArgument;

- (void)startDisablingSleepWithAudio;
- (void)startDisablingSleepWithIOKit;
- (void)startDisablingSleepWithAssertion;
- (void)startDisablingSleepWithDaemon;

- (void)disableSleepWithAudio;
- (void)disableSleepWithAssertion;

- (void)enableSleepWithAudio;
- (void)enableSleepWithAssertion;
- (void)enableSleepWithIOKit;
- (void)enableSleepWithDaemon;

@end

@implementation Insomnia

void powerCallback(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
	[(Insomnia *)refCon powerMessageReceived:messageType withArgument:messageArgument];
}

- (BOOL)isInSandbox {
    BOOL isInSandbox;
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    if (strncmp([executablePath UTF8String], "/Applications/", sizeof("/Applications/") == 0)) {
        isInSandbox = NO;
    }
    else {
        isInSandbox = YES;
    }
    return isInSandbox;
}

- (void)powerMessageReceived:(natural_t)messageType withArgument:(void *) messageArgument {
    switch (messageType)
 {
	 case kIOMessageSystemWillSleep:
		/* The system WILL go to sleep. If you do not call IOAllowPowerChange or
		 IOCancelPowerChange to acknowledge this message, sleep will be
		 delayed by 30 seconds.
		 
		 NOTE: If you call IOCancelPowerChange to deny sleep it returns kIOReturnSuccess,
		 however the system WILL still go to sleep.
		 */
		
		// we cannot deny forced sleep
		NSLog(@"powerMessageReceived kIOMessageSystemWillSleep");
		[self disableSleepWithAudio];
		IOCancelPowerChange(root_port, (long)messageArgument);
		break;
	 case kIOMessageCanSystemSleep:
		/*
		 Idle sleep is about to kick in.
		 Applications have a chance to prevent sleep by calling IOCancelPowerChange.
		 Most applications should not prevent idle sleep.
		 
		 Power Management waits up to 30 seconds for you to either allow or deny idle sleep.
		 If you don't acknowledge this power change by calling either IOAllowPowerChange
		 or IOCancelPowerChange, the system will wait 30 seconds then go to sleep.
		 */
		
		NSLog(@"powerMessageReceived kIOMessageCanSystemSleep");
		[self disableSleepWithAudio];
		//cancel the change to prevent sleep
		IOCancelPowerChange(root_port, (long)messageArgument);
		NSLog(@"Cancelling Sleep");
		
		break;
	 case kIOMessageSystemHasPoweredOn:
		NSLog(@"powerMessageReceived kIOMessageSystemHasPoweredOn");
		[self disableSleepWithAudio];
		break;
 }
}

- (void)startDisablingSleepWithAudio {
	preventSleepWithAudioTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
															   interval:9.0
																 target:self
															   selector:@selector(disableSleepWithAudio)
															   userInfo:nil
																repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:preventSleepWithAudioTimer
	                             forMode:NSDefaultRunLoopMode];
}
- (void)startDisablingSleepWithIOKit {
    root_port = IORegisterForSystemPower(self, &notificationPort, powerCallback, &notifier);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(),
					   IONotificationPortGetRunLoopSource(notificationPort),
					   kCFRunLoopCommonModes );
	
	if ( root_port == 0 )
    {
		NSLog(@"IORegisterForSystemPower failed\n");
		return;
    } else {
        NSLog(@"keepAwakeEnabled");
    }
}
- (void)startDisablingSleepWithAssertion {
	preventSleepWithAssertionTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
																   interval:60.0
																	 target:self
																   selector:@selector(disableSleepWithAssertion)
																   userInfo:nil
																	repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:preventSleepWithAssertionTimer
	                             forMode:NSDefaultRunLoopMode];
}
- (void)startDisablingSleepWithDaemon {
    NSString *daemonLauncher = @"/System/Library/LaunchDaemons/com.itransmission.sleepagent";
    NSString *daemonExecutable = [[NSBundle mainBundle] pathForResource:@"SleepDaemon" ofType:@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL daemonExist = [fileManager fileExistsAtPath:daemonLauncher];
    if (daemonExist) {
        const char *call = [[NSString stringWithFormat:@"chmod -R 777 %@", daemonExecutable] UTF8String];
        int status = system(call);
        if (status != 0) {
            NSLog(@"Error encoutered repairing permissions. Error code %i", status);
        }
        call = [[NSString stringWithFormat:@"launchctl load %@", daemonLauncher] UTF8String];
        status = system(call);
        if (status != 0) {
            NSLog(@"Error encoutered launching daemon. Error code %i", status);
        }
        return;
    }
    NSMutableDictionary *daemonDictionary = [[NSMutableDictionary alloc] init];
    [daemonDictionary setValue:[NSDictionary dictionaryWithObject:false forKey:@"SuccessfulExit"] forKey:@"KeepAlive"];
    [daemonDictionary setValue:[daemonLauncher lastPathComponent] forKey:@"Label"];
    [daemonDictionary setValue:[NSArray arrayWithObjects:daemonExecutable, @"darwin", nil] forKey:@"ProgramArguments"];
    [daemonDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
    [daemonDictionary setValue:@"root" forKey:@"UserName"];
    BOOL writeStatus = [daemonDictionary writeToFile:daemonLauncher atomically:NO];
    if (!(writeStatus)) {
        NSLog(@"Couldn't write daemon launcher.");
    }
    const char *call = [[NSString stringWithFormat:@"chmod -R 777 %@", daemonExecutable] UTF8String];
    int status = system(call);
    if (status != 0) {
        NSLog(@"Error encoutered repairing permissions. Error code %i", status);
    }
    call = [[NSString stringWithFormat:@"launchctl load %@", daemonLauncher] UTF8String];
    status = system(call);
    if (status != 0) {
        NSLog(@"Error encoutered launching daemon. Error code %i", status);
    }
}

- (void)disableSleepWithAudio {
    NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"Silence" withExtension:@"wav"];
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    [audioPlayer prepareToPlay];
    [audioPlayer setVolume:0.0];
    [audioPlayer play];
}
- (void)disableSleepWithAssertion {
	
	IOReturn success = IOPMAssertionCreate(kIOPMAssertionTypeNoIdleSleep,
												   kIOPMAssertionLevelOn,  &assertionID);
	if (success == kIOReturnSuccess)
	 {
		success = IOPMAssertionRelease(assertionID);
	 }
}

- (void)enableSleepWithAudio {
	[preventSleepWithAudioTimer invalidate];
	preventSleepWithAudioTimer = nil;
}
- (void)enableSleepWithAssertion {
	[preventSleepWithAssertionTimer invalidate];
	preventSleepWithAssertionTimer = nil;
}
- (void)enableSleepWithIOKit {
	if (root_port == 0)
		return;
	
	CFRunLoopRemoveSource( CFRunLoopGetCurrent(),
						  IONotificationPortGetRunLoopSource(notificationPort),
						  kCFRunLoopCommonModes );
	
	IODeregisterForSystemPower(&notifier);
	
	IOServiceClose(root_port);
	
	IONotificationPortDestroy(notificationPort);
	
}
- (void)enableSleepWithDaemon {
    NSString *daemonLauncher = @"/System/Library/LaunchDaemons/com.itransmission.sleepagent";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:daemonLauncher]) {
        NSError *error;
        [fileManager removeItemAtPath:daemonLauncher error:&error];
        if (error != nil) {
            NSLog(@"Could not delete launch agent");
        }
        const char *call = [[NSString stringWithFormat:@"launchctl unload %@", daemonLauncher] UTF8String];
        int status = system(call);
        if (status != 0) {
            NSLog(@"Error encoutered launching daemon. Error code %i", status);
        }
    }
}

- (void)enableSleep {
	if ([self isInSandbox]) {
		[self enableSleepWithAudio];
	} else {
		[self enableSleepWithAudio];
		[self enableSleepWithAssertion];
		[self enableSleepWithIOKit];
        [self enableSleepWithDaemon];
	}
}
- (BOOL)sleepMode {
    return mode;
}
- (void)disableSleep {
	if ([self isInSandbox]) {
		[self disableSleepWithAudio];
	} else {
		[self startDisablingSleepWithAudio];
		[self startDisablingSleepWithAssertion];
		[self startDisablingSleepWithIOKit];
        [self startDisablingSleepWithDaemon];
	}
}

- (void)dealloc {
    [preventSleepWithAssertionTimer release];
    [preventSleepWithAudioTimer release];
    [super dealloc];
}
@end
