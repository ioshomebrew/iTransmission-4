//
//  Controller.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "Torrent.h"
#import "Notifications.h"
#import "TorrentViewController.h"
#import "TorrentFetcher.h"
#import "Reachability.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import "ALAlertBanner.h"
#import <AVFoundation/AVFoundation.h>
#import "CFUserNotification.h"
#import "libtransmission/transmission.h"
#import "libtransmission/tr-getopt.h"
#import "libtransmission/log.h"
#import "libtransmission/utils.h"
#import "libtransmission/variant.h"
#import "libtransmission/version.h"
#include <stdlib.h> // setenv()

#define APP_NAME "iTrans"

static int ddLogLevel = LOG_LEVEL_VERBOSE;

static void
printMessage(int level, const char * name, const char * message, const char * file, int line )
{
    char timestr[64];
    tr_logGetTimeStr (timestr, sizeof (timestr));
    if( name )
        DDLogCVerbose(@"[%s] %s %s (%s:%d)", timestr, name, message, file, line );
}

static void pumpLogMessages()
{
    const tr_log_message * l;
    tr_log_message * list = tr_logGetQueue( );
    
    for( l=list; l!=NULL; l=l->next )
        printMessage(l->level, l->name, l->message, l->file, l->line );
    
    tr_logFreeQueue( list );
}

static tr_rpc_callback_status rpcCallback(tr_session *handle, tr_rpc_callback_type type, struct tr_torrent *torrentStruct, void *controller)
{
    [(__bridge Controller *)controller rpcCallback: type forTorrentStruct: torrentStruct];
    return TR_RPC_NOREMOVE; //we'll do the remove manually
}

static void signal_handler(int sig) {
    if (sig == SIGUSR1) {
        NSLog(@"Possibly entering background.");
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(Controller*)[[UIApplication sharedApplication] delegate] updateTorrentHistory];
    }
    return;
}

@implementation Controller

@synthesize window;
@synthesize navController;
@synthesize torrentViewController;
@synthesize activityCounter;
@synthesize reachability;
@synthesize logMessageTimer = fLogMessageTimer;
@synthesize installedApps = fInstalledApps;
@synthesize fileLogger = fFileLogger;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.torrentViewController = [[TorrentViewController alloc] initWithNibName:@"TorrentViewController" bundle:nil];
    self.torrentViewController.controller = self;
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.torrentViewController];
    self.navController.toolbarHidden = NO;
    
    self.installedApps = [self findRelatedApps];
    
    [self.window addSubview:self.navController.view];
	
    [self.window makeKeyAndVisible];
    
    /* start logging if needed */
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    if ([fDefaults objectForKey:@"LoggingEnabled"]) {
        [self startLogging];
        [self pumpLogMessages];
    }
    
    application.applicationIconBadgeNumber = 0;
    
    [self fixDocumentsDirectory];
	[self transmissionInitialize];

    return YES;
}

-(void) openApp {
    
    // the SpringboardServices.framework private framework can launch apps,
    //  so we open it dynamically and find SBSLaunchApplicationWithIdentifier()
    void* sbServices = dlopen(SBSERVPATH, RTLD_LAZY);
    int (*SBSLaunchApplicationWithIdentifier)(CFStringRef identifier, Boolean suspended) = dlsym(sbServices, "SBSLaunchApplicationWithIdentifier");
    SBSLaunchApplicationWithIdentifier(CFSTR("com.ioshomebrew.itransmission"), false);
    dlclose(sbServices);
}

-(void) showAlert {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject: @"Alert!" forKey: (__bridge NSString*)kCFUserNotificationAlertHeaderKey];
    [dict setObject: @"Updates Ready!" forKey: (__bridge NSString*)kCFUserNotificationAlertMessageKey];
    [dict setObject: @"View" forKey:(__bridge NSString*)kCFUserNotificationDefaultButtonTitleKey];
    [dict setObject: @"Cancel" forKey:(__bridge NSString*)kCFUserNotificationAlternateButtonTitleKey];
    
    SInt32 error = 0;
    CFUserNotificationRef alert = CFUserNotificationCreate(NULL, 0, kCFUserNotificationPlainAlertLevel, &error, (__bridge CFDictionaryRef)dict);
    
    CFOptionFlags response;
    // we block, waiting for a response, for up to 10 seconds
    if((error) || (CFUserNotificationReceiveResponse(alert, 10, &response))) {
        NSLog(@"alert error or no user response after 10 seconds");
    } else if((response & 0x3) == kCFUserNotificationAlternateResponse) {
        // user clicked on Cancel ... just do nothing
        NSLog(@"cancel");
    } else if((response & 0x3) == kCFUserNotificationDefaultResponse) {
        // user clicked on View ... so, open the UI App
        NSLog(@"view");
        [self openApp];
    }
    CFRelease(alert);
}

- (id)infoValueForKey:(NSString *)key
{
    // fetch objects from our bundle based on keys in our Info.plist
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (NSArray*)findRelatedApps
{
    NSMutableArray *ret = [NSMutableArray array];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ifile://"]]) {
        [ret addObject:@"ifile"];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        [ret addObject:@"cydia"];
    }
    
    return [NSArray arrayWithArray:ret];
}

- (void)pumpLogMessages
{
    pumpLogMessages();
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"magnet"]) {
        [self addTorrentFromManget:[url absoluteString]];
        return YES;
    } else {
        [self addTorrentFromURL:[url absoluteString]];
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return YES;
}

- (void)resetToDefaultPreferences
{
    [NSUserDefaults resetStandardUserDefaults];
    fDefaults = [NSUserDefaults standardUserDefaults];
    [fDefaults setBool:YES forKey:@"SpeedLimitAuto"];
    [fDefaults setBool:NO forKey:@"AutoStartDownload"];
    [fDefaults setBool:YES forKey:@"DHTGlobal"];
    [fDefaults setInteger:0 forKey:@"DownloadLimit"];
    [fDefaults setInteger:0 forKey:@"UploadLimit"];
    [fDefaults setBool:NO forKey:@"DownloadLimitEnabled"];
    [fDefaults setBool:NO forKey:@"UploadLimitEnabled"];
    [fDefaults setObject:[self defaultDownloadDir] forKey:@"DownloadFolder"];
    [fDefaults setObject:[self defaultDownloadDir] forKey:@"IncompleteDownloadFolder"];
    [fDefaults setBool:NO forKey:@"UseIncompleteDownloadFolder"];
    [fDefaults setBool:YES forKey:@"LocalPeerDiscoveryGlobal"];
    [fDefaults setInteger:30 forKey:@"PeersTotal"];
    [fDefaults setInteger:20 forKey:@"PeersTorrent"];
    [fDefaults setBool:NO forKey:@"RandomPort"];
    [fDefaults setInteger:30901 forKey:@"BindPort"];
    [fDefaults setInteger:0 forKey:@"PeerSocketTOS"];
    [fDefaults setBool:YES forKey:@"PEXGlobal"];
    [fDefaults setBool:YES forKey:@"NatTraversal"];
    [fDefaults setBool:NO forKey:@"Proxy"];
    [fDefaults setInteger:0 forKey:@"ProxyPort"];
    [fDefaults setFloat:0.0f forKey:@"RatioLimit"];
    [fDefaults setBool:NO forKey:@"RatioCheck"];
    [fDefaults setBool:YES forKey:@"RenamePartialFiles"];
    [fDefaults setBool:NO forKey:@"RPCAuthorize"];
    [fDefaults setBool:NO forKey:@"RPC"];
	[fDefaults setObject:@"" forKey:@"RPCUsername"];
    [fDefaults setObject:@"" forKey:@"RPCPassword"];
	[fDefaults setInteger:9091 forKey:@"RPCPort"];
    [fDefaults setBool:NO forKey:@"RPCUseWhitelist"];
	[fDefaults setBool:YES forKey:@"UseWiFi"];
	[fDefaults setBool:NO forKey:@"UseCellularNetwork"];
    [fDefaults setBool:NO forKey:@"BackgroundDownloading"];
	[fDefaults synchronize];
}

- (void)transmissionInitialize
{
	fDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![fDefaults boolForKey:@"NotFirstRun"]) {
        [self resetToDefaultPreferences];
        [fDefaults setBool:YES forKey:@"NotFirstRun"];
        [self performSelector:@selector(firstRunMessage) withObject:nil afterDelay:0.5f];
    }
    
    //checks for old version speeds of -1
    if ([fDefaults integerForKey: @"UploadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"UploadLimit"];
        [fDefaults setBool: NO forKey: @"CheckUpload"];
    }
    if ([fDefaults integerForKey: @"DownloadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"DownloadLimit"];
        [fDefaults setBool: NO forKey: @"CheckDownload"];
    }
    
    tr_variantInitDict(&settings, 41);
    tr_sessionGetDefaultSettings(&settings);
    
    tr_variantDictAddBool(&settings, TR_KEY_alt_speed_enabled, [fDefaults boolForKey: @"SpeedLimit"]);
    
	tr_variantDictAddBool(&settings, TR_KEY_alt_speed_time_enabled, NO);
    
//	tr_variantDictAddBool(&settings, TR_KEY_START, [fDefaults boolForKey: @"AutoStartDownload"]);
	
    tr_variantDictAddInt(&settings, TR_KEY_speed_limit_down, [fDefaults integerForKey: @"DownloadLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_speed_limit_down_enabled, [fDefaults boolForKey: @"DownloadLimitEnabled"]);
    tr_variantDictAddInt(&settings, TR_KEY_speed_limit_up, [fDefaults integerForKey: @"UploadLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_speed_limit_up_enabled, [fDefaults boolForKey: @"UploadLimitEnabled"]);
	
    //	if ([fDefaults objectForKey: @"BindAddressIPv4"])
    //		tr_variantDictAddStr(&settings, TR_KEY_BIND_ADDRESS_IPV4, [[fDefaults stringForKey: @"BindAddressIPv4"] UTF8String]);
    //	if ([fDefaults objectForKey: @"BindAddressIPv6"])
    //		tr_variantDictAddStr(&settings, TR_KEY_BIND_ADDRESS_IPV6, [[fDefaults stringForKey: @"BindAddressIPv6"] UTF8String]);
    
	tr_variantDictAddBool(&settings, TR_KEY_blocklist_enabled, [fDefaults boolForKey: @"Blocklist"]);
	tr_variantDictAddBool(&settings, TR_KEY_dht_enabled, [fDefaults boolForKey: @"DHTGlobal"]);
	tr_variantDictAddStr(&settings, TR_KEY_download_dir, [[self defaultDownloadDir] cStringUsingEncoding:NSASCIIStringEncoding]);
	tr_variantDictAddStr(&settings, TR_KEY_download_dir, [[[fDefaults stringForKey: @"DownloadFolder"]
															  stringByExpandingTildeInPath] UTF8String]);
	tr_variantDictAddStr(&settings, TR_KEY_incomplete_dir, [[[fDefaults stringForKey: @"IncompleteDownloadFolder"]
																stringByExpandingTildeInPath] UTF8String]);
	tr_variantDictAddBool(&settings, TR_KEY_incomplete_dir_enabled, [fDefaults boolForKey: @"UseIncompleteDownloadFolder"]);

	tr_variantDictAddBool(&settings, TR_KEY_lpd_enabled, [fDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
	tr_variantDictAddInt(&settings, TR_KEY_message_level, TR_LOG_DEBUG);
	tr_variantDictAddInt(&settings, TR_KEY_peer_limit_global, [fDefaults integerForKey: @"PeersTotal"]);
	tr_variantDictAddInt(&settings,  TR_KEY_peer_limit_per_torrent, [fDefaults integerForKey: @"PeersTorrent"]);
	
	const BOOL randomPort = [fDefaults boolForKey: @"RandomPort"];
	tr_variantDictAddBool(&settings, TR_KEY_peer_port_random_on_start, randomPort);
	if (!randomPort)
		tr_variantDictAddInt(&settings, TR_KEY_peer_port, [fDefaults integerForKey: @"BindPort"]);
	
	//hidden pref
	if ([fDefaults objectForKey: @"PeerSocketTOS"])
		tr_variantDictAddInt(&settings, TR_KEY_peer_socket_tos, [fDefaults integerForKey: @"PeerSocketTOS"]);
	
    tr_variantDictAddBool(&settings, TR_KEY_pex_enabled, [fDefaults boolForKey: @"PEXGlobal"]);
    tr_variantDictAddBool(&settings, TR_KEY_port_forwarding_enabled, [fDefaults boolForKey: @"NatTraversal"]);
    tr_variantDictAddReal(&settings, TR_KEY_ratio_limit, [fDefaults floatForKey: @"RatioLimit"]);
    tr_variantDictAddBool(&settings, TR_KEY_ratio_limit, [fDefaults boolForKey: @"RatioCheck"]);
    tr_variantDictAddBool(&settings, TR_KEY_rename_partial_files, [fDefaults boolForKey: @"RenamePartialFiles"]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_authentication_required,  [fDefaults boolForKey: @"RPCAuthorize"]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_enabled,  [fDefaults boolForKey: @"RPC"]);
    tr_variantDictAddInt(&settings, TR_KEY_rpc_port, [fDefaults integerForKey: @"RPCPort"]);
    tr_variantDictAddStr(&settings, TR_KEY_rpc_username,  [[fDefaults stringForKey: @"RPCUsername"] UTF8String]);
    tr_variantDictAddBool(&settings, TR_KEY_rpc_whitelist_enabled,  [fDefaults boolForKey: @"RPCUseWhitelist"]);
    tr_variantDictAddBool(&settings, TR_KEY_start_added_torrents, [fDefaults boolForKey: @"AutoStartDownload"]);
    tr_variantDictAddBool(&settings, TR_KEY_script_torrent_done_enabled, [fDefaults boolForKey: @"DoneScriptEnabled"]);
    tr_variantDictAddStr(&settings, TR_KEY_script_torrent_done_filename, [[fDefaults stringForKey: @"DoneScriptPath"] UTF8String]);
    tr_variantDictAddBool(&settings, TR_KEY_utp_enabled, [fDefaults boolForKey: @"UTPGlobal"]);
    
    tr_formatter_size_init(1000, [NSLocalizedString(@"KB", "File size - kilobytes") UTF8String],
                           [NSLocalizedString(@"MB", "File size - megabytes") UTF8String],
                           [NSLocalizedString(@"GB", "File size - gigabytes") UTF8String],
                           [NSLocalizedString(@"TB", "File size - terabytes") UTF8String]);
    
    tr_formatter_speed_init(1000,
                            [NSLocalizedString(@"KB/s", "Transfer speed (kilobytes per second)") UTF8String],
                            [NSLocalizedString(@"MB/s", "Transfer speed (megabytes per second)") UTF8String],
                            [NSLocalizedString(@"GB/s", "Transfer speed (gigabytes per second)") UTF8String],
                            [NSLocalizedString(@"TB/s", "Transfer speed (terabytes per second)") UTF8String]); //why not?
    
    tr_formatter_mem_init(1024, [NSLocalizedString(@"KB", "Memory size - kilobytes") UTF8String],
                          [NSLocalizedString(@"MB", "Memory size - megabytes") UTF8String],
                          [NSLocalizedString(@"GB", "Memory size - gigabytes") UTF8String],
                          [NSLocalizedString(@"TB", "Memory size - terabytes") UTF8String]);
	
	fLib = tr_sessionInit("macosx", [[self configDir] cStringUsingEncoding:NSASCIIStringEncoding], YES, &settings);
	tr_variantFree(&settings);
    
    NSString *webDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    if (setenv("TRANSMISSION_WEB_HOME", [webDir cStringUsingEncoding:NSUTF8StringEncoding], 1)) {
        NSLog(@"Failed to set \"TRANSMISSION_WEB_HOME\" environmental variable. ");
    }
	
	fTorrents = [[NSMutableArray alloc] init];	
    fActivities = [[NSMutableArray alloc] init];
    tr_sessionSetRPCCallback(fLib, rpcCallback, (__bridge void *)(self));
    
	fUpdateInProgress = NO;
	
	fPauseOnLaunch = YES;
//    tr_sessionSaveSettings(fLib, [[self configDir] cStringUsingEncoding:NSUTF8StringEncoding], &settings);
    
    [self loadTorrentHistory];
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkInterfaceChanged:) name:kReachabilityChangedNotification object:self.reachability];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentFinished:) name:@"TorrentFinishedDownloading" object:nil];
	[self.reachability startNotifier];
    [self postFinishMessage:@"Initialization finished."];
}

- (tr_session*)rawSession
{
    return fLib;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSTimer *updateTimer;
    if ([self.navController.visibleViewController respondsToSelector:@selector(UIUpdateTimer)]) {
        updateTimer = [(StatisticsViewController*)self.navController.visibleViewController UIUpdateTimer];
        [updateTimer invalidate];
        [(StatisticsViewController*)self.navController.visibleViewController setUIUpdateTimer:nil];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    /*
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSTimer *updateTimer;
    if ([self.navController.visibleViewController respondsToSelector:@selector(UIUpdateTimer)]) {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self.navController.visibleViewController selector:@selector(updateUI) userInfo:nil repeats:YES];
        [(StatisticsViewController*)self.navController.visibleViewController setUIUpdateTimer:updateTimer];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[self updateTorrentHistory];
    tr_sessionClose(fLib);
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (NSString*)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
    
    // I want iTunes backup & restore features. 
//    NSError *error = nil;
//#if TARGET_IPHONE_SIMULATOR
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    return documentsDirectory;
//#else
//    NSString *documentsDirectoryOutsideSandbox = @"/var/mobile/iTransmission/";
//    if ([[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectoryOutsideSandbox withIntermediateDirectories:YES attributes:nil error:&error]) {
//        return documentsDirectoryOutsideSandbox;
//    }
//    else {
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        return documentsDirectory;
//    }
//#endif
}

- (NSString*)defaultDownloadDir
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Downloads"];
}

- (NSString*)transferPlist
{
	return [[self documentsDirectory] stringByAppendingPathComponent:@"Transfer.plist"];
}

- (NSString*)torrentsPath
{
	return [[self documentsDirectory] stringByAppendingPathComponent:@"torrents"];
}

- (NSString*)configDir
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"config"];
}

- (void)networkInterfaceChanged:(NSNotification*)notif
{
	NetworkStatus status = [self.reachability currentReachabilityStatus];
	[self setActiveForNetworkStatus:status];
}

- (void)updateNetworkStatus
{
	[self setActiveForNetworkStatus:[self.reachability currentReachabilityStatus]];
}

- (BOOL)isSessionActive
{
	return [self isStartingTransferAllowed];
}

- (BOOL)isStartingTransferAllowed
{
	NetworkStatus status = [self.reachability currentReachabilityStatus];
	if (status == ReachableViaWiFi && [fDefaults boolForKey:@"UseWiFi"] == NO) return NO;
	if (status == ReachableViaWWAN && [fDefaults boolForKey:@"UseCellularNetwork"] == NO) return NO;
	if (status == NotReachable) return NO;
	return YES;
}

- (void)postError:(NSString *)err_msg
{
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleFailure position:ALAlertBannerPositionUnderNavBar title:err_msg];
    banner.secondsToShow = 3.5f;
    banner.showAnimationDuration = 0.25f;
    banner.hideAnimationDuration = 0.2f;
    [banner show];
}

- (void)postMessage:(NSString*)msg
{
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleNotify position:ALAlertBannerPositionUnderNavBar title:msg];
    banner.secondsToShow = 3.5f;
    banner.showAnimationDuration = 0.25f;
    banner.hideAnimationDuration = 0.2f;
    [banner show];
}

- (void)postFinishMessage:(NSString*)msg
{
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.window style:ALAlertBannerStyleSuccess position:ALAlertBannerPositionUnderNavBar title:msg subtitle:msg];
    [banner show];
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:msg];
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)setActiveForNetworkStatus:(NetworkStatus)status
{
	if (status == ReachableViaWiFi) {
		if ([fDefaults boolForKey:@"UseWiFi"] == NO) {
			[self postMessage:@"Switched to WiFi. Pausing..."];
			for (Torrent *t in fTorrents) {
				[t sleep];
			}
		}
        else {
            [self postMessage:@"Switched to WiFi. Resuming..."];
            for (Torrent *t in fTorrents) {
				[t wakeUp];
			}
        }
	}
	else if (status == NotReachable) {
		[self postError:@"Network is down!"];
	}
	else if (status == ReachableViaWWAN) {
		if ([fDefaults boolForKey:@"UseCellularNetwork"] == NO) {
			[self postMessage:@"Switched to cellular network. Pausing..."];
			for (Torrent *t in fTorrents) {
				[t sleep];
			}
		}
        else {
            [self postMessage:@"Switched to cellular network. Resuming..."];
            for (Torrent *t in fTorrents) {
				[t wakeUp];
			}
        }
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationSessionStatusChanged object:self userInfo:nil];
}

- (CGFloat)globalDownloadSpeed
{
    return fGlobalSpeedCached[0];
}

- (void)updateGlobalSpeed
{
    [fTorrents makeObjectsPerformSelector: @selector(update)];

    CGFloat dlRate = 0.0, ulRate = 0.0;
    for (Torrent * torrent in fTorrents)
    {
        dlRate += [torrent downloadRate];
        ulRate += [torrent uploadRate];
    }
    
    fGlobalSpeedCached[0] = dlRate;
    fGlobalSpeedCached[1] = ulRate;
}

- (CGFloat)globalUploadSpeed
{
    return fGlobalSpeedCached[1];
}

- (void)fixDocumentsDirectory
{
    BOOL isDir, exists;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSLog(@"Using documents directory %@", [self documentsDirectory]);
    
    NSArray *directories = [NSArray arrayWithObjects:[self documentsDirectory], [self configDir], [self torrentsPath], [self defaultDownloadDir], nil];
    
    for (NSString *d in directories) {
        exists = [fileManager fileExistsAtPath:d isDirectory:&isDir];
        if (exists && !isDir) {
            [fileManager removeItemAtPath:d error:nil];
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
        if (!exists) {
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
    }
}

- (NSString*)randomTorrentPath
{
    return [[self torrentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.torrent", [[NSDate date] timeIntervalSince1970]]];
}

- (void)updateTorrentHistory
{    
    NSMutableArray * history = [NSMutableArray arrayWithCapacity: [fTorrents count]];
    
    for (Torrent * torrent in fTorrents)
        [history addObject: [torrent history]];
    
    [history writeToFile: [self transferPlist] atomically: YES];
    
}

- (void)loadTorrentHistory
{
    NSArray * history = [NSArray arrayWithContentsOfFile: [self transferPlist]];
        
    if (!history)
    {
        //old version saved transfer info in prefs file
        if ((history = [fDefaults arrayForKey: @"History"]))
            [fDefaults removeObjectForKey: @"History"];
    }
    
    if (history)
    {
        for (NSDictionary * historyItem in history)
        {
            Torrent * torrent;
            if ((torrent = [[Torrent alloc] initWithHistory: historyItem lib: fLib forcePause:NO]))
            {
                [torrent changeDownloadFolderBeforeUsing:[self defaultDownloadDir]];
                [fTorrents addObject: torrent];
            }
        }
    }
}

- (NSUInteger)torrentsCount
{
    return [fTorrents count];
}

- (Torrent*)torrentAtIndex:(NSInteger)index
{
    return [fTorrents objectAtIndex:index];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher fetchedTorrentContent:(NSData *)data fromURL:(NSString *)url
{
    NSError *error = nil;
    [self decreaseActivityCounter];
    NSString *path = [self randomTorrentPath];
    [data writeToFile:path options:0 error:&error];
    error = [self openFile:path addType:ADD_URL forcePath:nil];
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Add from URL" message:[NSString stringWithFormat:@"Adding from %@ failed. %@", url, [error localizedDescription]]  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
    [fActivities removeObject:fetcher];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher failedToFetchFromURL:(NSString *)url withError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add torrent" message:[NSString stringWithFormat:@"Failed to fetch torrent URL: \"%@\". \nError: %@", url, [error localizedDescription]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    [fActivities removeObject:fetcher];    
    [self decreaseActivityCounter];
}

- (void)removeTorrents:(NSArray*)torrents trashData:(BOOL)trashData
{
	for (Torrent *torrent in torrents) {
		[torrent stopTransfer];
		[torrent closeRemoveTorrent:trashData];
		[fTorrents removeObject:torrent];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationTorrentsRemoved object:self userInfo:nil];
}

- (void)removeTorrents:(NSArray *)torrents trashData:(BOOL)trashData afterDelay:(NSTimeInterval)delay
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:torrents forKey:@"torrents"];
    [options setObject:[NSNumber numberWithBool:trashData] forKey:@"trashData"];
    [self performSelector:@selector(_removeTorrentsDelayed:) withObject:options afterDelay:delay];
}

- (void)_removeTorrentsDelayed:(NSDictionary*)options
{
    BOOL trashData = [[options objectForKey:@"trashData"] boolValue];
    NSArray *torrents = [options objectForKey:@"torrents"];
    [self removeTorrents:torrents trashData:trashData];
}

- (void)addTorrentFromURL:(NSString*)url
{
    TorrentFetcher *fetcher = [[TorrentFetcher alloc] initWithURLString:url delegate:self];
    [fActivities addObject:fetcher];
    [self increaseActivityCounter];
}

- (void)firstRunMessage
{
    NSString *firstRunMessage = @"Hello, and enjoy downloading!";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                        message:firstRunMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"I got it!"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (NSError*)addTorrentFromManget:(NSString *)magnet
{
    NSError *err = nil;
    
    tr_torrent * duplicateTorrent;
    if ((duplicateTorrent = tr_torrentFindFromMagnetLink(fLib, [magnet UTF8String])))
    {
        const tr_info * info = tr_torrentInfo(duplicateTorrent);
        NSString * name = (info != NULL && info->name != NULL) ? [NSString stringWithUTF8String: info->name] : nil;
        err = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %@ already exists. ", name] forKey:NSLocalizedDescriptionKey]];
        return err;
    }
    
    //determine download location
    NSString * location = nil;
    if ([fDefaults boolForKey: @"DownloadLocationConstant"])
        location = [[fDefaults stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath];
    
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithMagnetAddress: magnet location: location lib: fLib]))
    {
        err = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:@"The magnet supplied is invalid." forKey:NSLocalizedDescriptionKey]];
        return err;
    }
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject: torrent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (NSError*)openFile:(NSString*)file addType:(AddType)type forcePath:(NSString *)path
{
    NSError *error = nil;
    tr_ctor * ctor = tr_ctorNew(fLib);
    tr_ctorSetMetainfoFromFile(ctor, [file UTF8String]);
    
    tr_info info;
    const tr_parse_result result = tr_torrentParse(ctor, &info);
    tr_ctorFree(ctor);
    
    // TODO: instead of alert view, print errors in activities view. 
    if (result != TR_PARSE_OK)
    {
        if (result == TR_PARSE_DUPLICATE) {
            error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %s already exists. ", info.name] forKey:NSLocalizedDescriptionKey]];
        }
        else if (result == TR_PARSE_ERR)
        {
            error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid torrent file. "] forKey:NSLocalizedDescriptionKey]];
        }
        tr_metainfoFree(&info);
        return error;
    }
    
    
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithPath:file location: [path stringByExpandingTildeInPath] deleteTorrentFile: NO lib: fLib])) {
        error = [[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unknown error. "] forKey:NSLocalizedDescriptionKey]];
        return error;
    }
    
    //verify the data right away if it was newly created
    if (type == ADD_CREATED)
        [torrent resetCache];
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject: torrent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (void)increaseActivityCounter
{
    activityCounter += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}

- (void)decreaseActivityCounter
{
    if (activityCounter == 0) return;
    activityCounter -= 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}

- (void) rpcCallback: (tr_rpc_callback_type) type forTorrentStruct: (struct tr_torrent *) torrentStruct
{
    //get the torrent
    Torrent * torrent = nil;
    if (torrentStruct != NULL && (type != TR_RPC_TORRENT_ADDED && type != TR_RPC_SESSION_CHANGED))
    {
        for (torrent in fTorrents)
            if (torrentStruct == [torrent torrentStruct])
            {
                break;
            }
        
        if (!torrent)
        {
            NSLog(@"No torrent found matching the given torrent struct from the RPC callback!");
            return;
        }
    }
    
    switch (type)
    {
        case TR_RPC_TORRENT_ADDED:
            [self performSelectorOnMainThread: @selector(rpcAddTorrentStruct:) withObject:
			 [NSValue valueWithPointer: torrentStruct] waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_STARTED:
        case TR_RPC_TORRENT_STOPPED:
            [self performSelectorOnMainThread: @selector(rpcStartedStoppedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_REMOVING:
            [self performSelectorOnMainThread: @selector(rpcRemoveTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_CHANGED:
            [self performSelectorOnMainThread: @selector(rpcChangedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_MOVED:
            [self performSelectorOnMainThread: @selector(rpcMovedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_SESSION_CHANGED:
            //TODO: Post notification to update preferences. 
            break;
			
        default:
            NSAssert1(NO, @"Unknown RPC command received: %d", type);
    }
}

- (void) rpcAddTorrentStruct: (NSValue *) torrentStructPtr
{
    tr_torrent * torrentStruct = (tr_torrent *)[torrentStructPtr pointerValue];
    
    NSString * location = nil;
    if (tr_torrentGetDownloadDir(torrentStruct) != NULL)
        location = [NSString stringWithUTF8String: tr_torrentGetDownloadDir(torrentStruct)];
    
    Torrent * torrent = [[Torrent alloc] initWithTorrentStruct: torrentStruct location: location lib: fLib];
    
    [torrent update];
    [fTorrents addObject: torrent];
}

- (void) rpcRemoveTorrent: (Torrent *) torrent
{
    [self removeTorrents:[NSArray arrayWithObject: torrent] trashData:NO];
}

- (void) rpcStartedStoppedTorrent: (Torrent *) torrent
{
    [torrent update];
    
	//TODO: Post notification to update this torrent's info in UI. 
	
    [self updateTorrentHistory];
}

- (void) rpcChangedTorrent: (Torrent *) torrent
{
    [torrent update];
    
	//TODO: Post notification to update this torrent's info in UI.
}

- (void) rpcMovedTorrent: (Torrent *) torrent
{
    [torrent update];
}


- (void)setGlobalUploadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"UploadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_UP, (unsigned int)[fDefaults integerForKey:@"UploadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_UP): %d", tr_sessionIsSpeedLimited(fLib, TR_UP));
}

- (void)setGlobalDownloadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"DownloadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_DOWN, (unsigned int)[fDefaults integerForKey:@"DownloadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_DOWN): %d", tr_sessionIsSpeedLimited(fLib, TR_DOWN));
}

- (void)setGlobalUploadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"UploadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_UP, [fDefaults boolForKey:@"UploadLimitEnabled"]);
}

- (void)setGlobalDownloadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"DownloadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_DOWN, [fDefaults boolForKey:@"DownloadLimitEnabled"]);
}

- (NSInteger)globalDownloadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_DOWN);
}

- (NSInteger)globalUploadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_UP);
}

- (void)setGlobalMaximumConnections:(NSInteger)c
{
    [fDefaults setInteger:c forKey:@"PeersTotal"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimit(fLib, c);
}

- (NSInteger)globalMaximumConnections
{
    return tr_sessionGetPeerLimit(fLib);
}

- (void)setConnectionsPerTorrent:(NSInteger)c
{
    [fDefaults setInteger:c forKey:@"PeersTorrent"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimitPerTorrent(fLib, c);
}

- (NSInteger)connectionsPerTorrent
{
    return tr_sessionGetPeerLimitPerTorrent(fLib);
}

- (BOOL)globalUploadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_UP);
}

- (BOOL)globalDownloadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_DOWN);
}

- (BOOL)isLoggingEnabled
{
    return (self.fileLogger != nil);
}

- (void)startLogging
{
    if (![self isLoggingEnabled]) {
        self.fileLogger = [[DDFileLogger alloc] init];
        self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:self.fileLogger];
        self.logMessageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(pumpLogMessages) userInfo:nil repeats:YES];
    }
}

- (void)stopLogging
{
    if ([self isLoggingEnabled]) {
        [DDLog removeLogger:self.fileLogger];
        self.fileLogger = nil;
        [self.logMessageTimer invalidate];
        self.logMessageTimer = nil;
    }
}

- (void)setLoggingEnabled:(BOOL)enabled
{
    if (enabled) {
        [self startLogging];
    }
    else {
        [self stopLogging];
    }
}

- (void)torrentFinished:(NSNotification*)notif {
    [self postBGNotif:[NSString stringWithFormat:NSLocalizedString(@"%@ download finished.", nil), [(Torrent *)[notif object] name]]];
    [self postFinishMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ download finished.", nil), [(Torrent *)[notif object] name]]];
}

- (void)postBGNotif:(NSString *)message {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		UILocalNotification *localNotif = [[UILocalNotification alloc] init];
		if (localNotif == nil)
			return;
		localNotif.fireDate = nil;//Immediately
		
		// Notification details
		localNotif.alertBody = message;
		// Set the action button
		localNotif.alertAction = @"View";
		
		localNotif.soundName = UILocalNotificationDefaultSoundName;
		localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
		
		// Specify custom data for the notification
		//NSDictionary *infoDict = [NSDictionary dictionaryWithObject:file forKey:@"Downloaded"];
		//localNotif.userInfo = infoDict;
		
		// Schedule the notification
		[[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
	}
} 

@end
