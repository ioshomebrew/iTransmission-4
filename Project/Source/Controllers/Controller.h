/******************************************************************************
 * Part of this file is copied from Controller.h in Transmission project
 * Original copyright declaration is as follows. 
 *****************************************************************************/

/******************************************************************************
 * $Id: Controller.h 10465 2010-04-12 00:55:31Z livings124 $
 *
 * Copyright (c) 2005-2010 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/


#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "TorrentFetcher.h"
#import "libtransmission/transmission.h"
#include <dlfcn.h>
#define SBSERVPATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

typedef enum
{
    ADD_MANUAL,
    ADD_AUTO,
    ADD_SHOW_OPTIONS,
    ADD_URL,
    ADD_CREATED
} AddType;

@class Torrent;
@class TorrentViewController;
@class Reachability;
@class DDFileLogger;

extern BOOL isStartingTransferAllowed();

#define PREF_

@interface Controller : NSObject <UIApplicationDelegate, TorrentFetcherDelegate> {
    UIWindow *window;
	NSUserDefaults *fDefaults;
	tr_session *fLib;
	NSMutableArray * fTorrents;
    NSMutableArray * fActivities;
	BOOL fPauseOnLaunch;
	BOOL fUpdateInProgress;
    tr_variant settings;
    
    UINavigationController *navController;
    TorrentViewController *torrentViewController;
    NSInteger activityCounter;
	Reachability *reachability;
    
    NSArray *fInstalledApps;
    
    CGFloat fGlobalSpeedCached[2];
    
    NSTimer *fLogMessageTimer;
    DDFileLogger *fFileLogger;
    
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) TorrentViewController *torrentViewController;
@property (nonatomic, readonly) NSInteger activityCounter;
@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, retain) NSArray *installedApps;
@property (nonatomic, retain) NSTimer *logMessageTimer;
@property (nonatomic, retain) DDFileLogger *fileLogger;

- (void)transmissionInitialize;
- (NSArray*)findRelatedApps;

- (void)rpcCallback: (tr_rpc_callback_type) type forTorrentStruct: (struct tr_torrent *) torrentStruct;
- (void)rpcAddTorrentStruct: (NSValue *) torrentStructPtr;
- (void)rpcRemoveTorrent: (Torrent *) torrent;
- (void)rpcStartedStoppedTorrent: (Torrent *) torrent;
- (void)rpcChangedTorrent: (Torrent *) torrent;
- (void)rpcMovedTorrent: (Torrent *) torrent;

- (NSString*)transferPlist;
- (NSString*)torrentsPath;
- (NSString*)randomTorrentPath;
- (NSString*)defaultDownloadDir;
- (NSString*)configDir;
- (NSString*)documentsDirectory;
- (void)updateTorrentHistory;
- (void)loadTorrentHistory;
- (void)resetToDefaultPreferences;

- (tr_session*)rawSession;

- (void)firstRunMessage;
- (void)fixDocumentsDirectory;

- (CGFloat)globalDownloadSpeed;
- (CGFloat)globalUploadSpeed;

- (NSUInteger)torrentsCount;
- (Torrent*)torrentAtIndex:(NSInteger)index;

- (void)addTorrentFromURL:(NSString*)url;
- (NSError*)addTorrentFromManget:(NSString*)magnet;
- (NSError*)openFile:(NSString*)file addType:(AddType)type forcePath:(NSString *) path;
- (void)removeTorrents:(NSArray*)torrents trashData:(BOOL)trashData;
- (void)removeTorrents:(NSArray *)torrents trashData:(BOOL)trashData afterDelay:(NSTimeInterval)delay;
- (void)_removeTorrentsDelayed:(NSDictionary*)options;
- (void)increaseActivityCounter;
- (void)decreaseActivityCounter;

- (void)networkInterfaceChanged:(NSNotification*)notif;
- (void)setActiveForNetworkStatus:(NetworkStatus)status;
- (void)updateNetworkStatus;
- (BOOL)isStartingTransferAllowed;
- (BOOL)isSessionActive;

- (void)postError:(NSString*)err_msg;
- (void)postMessage:(NSString*)msg;
- (void)postFinishMessage:(NSString*)msg;

- (void)setGlobalUploadSpeedLimit:(NSInteger)kbytes;
- (void)setGlobalDownloadSpeedLimit:(NSInteger)kbytes;
- (void)setGlobalUploadSpeedLimitEnabled:(BOOL)enabled;
- (void)setGlobalDownloadSpeedLimitEnabled:(BOOL)enabled;
- (BOOL)globalUploadSpeedLimitEnabled;
- (BOOL)globalDownloadSpeedLimitEnabled;
- (NSInteger)globalDownloadSpeedLimit;
- (NSInteger)globalUploadSpeedLimit;
- (void)setGlobalMaximumConnections:(NSInteger)c;
- (NSInteger)globalMaximumConnections;
- (void)setConnectionsPerTorrent:(NSInteger)c;
- (NSInteger)connectionsPerTorrent;
- (void)pumpLogMessages;
- (void)updateGlobalSpeed;
- (BOOL)isLoggingEnabled;
- (void)setLoggingEnabled:(BOOL)enabled;
- (void)startLogging;
- (void)stopLogging;

- (void)torrentFinished:(NSNotification*)notif;
- (void)postBGNotif:(NSString *)message;
- (id)infoValueForKey:(NSString *)key;
-(void) openApp;
-(void) showAlert;

@end

