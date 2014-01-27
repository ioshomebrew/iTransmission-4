//
//  TorrentAutoDiscoveryController.h
//  iTransmission
//
//  Created by Mike Chen on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface DiscoveredTorrentFile : NSObject<NSCoding> {
@private
    NSString *filepath;
}
@property (nonatomic, retain) NSString *filepath;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) NSString *directory;

- (id)initWithFilepath:(NSString*)path;

@end

typedef enum _AutoDiscoveryState {
    AutoDiscoveryStateIdle,
    AutoDiscoveryStateWorking,
} AutoDiscoveryState;

@class Controller;

@interface TorrentAutoDiscoveryController : UITableViewController<EGORefreshTableHeaderDelegate, UIScrollViewDelegate, UISearchDisplayDelegate> {
    NSArray *fSearchDirectories;
    EGORefreshTableHeaderView *fRefreshHeaderView;
    NSMutableArray *fDiscoveredTorrents;
    NSMutableArray *fSearchResults;
    AutoDiscoveryState state;
    NSFileManager *fFileManager;
    NSThread *fAutoDiscoveryThread;
    NSDate *fLastDiscoveryDate;
    UITableView *fTableView;
    UISearchBar *fSearchBar;
    Controller *fController;
}
@property (nonatomic, retain) NSArray *searchDirectories;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) NSMutableArray *discoveredTorrents;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, readonly) AutoDiscoveryState state;
@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, retain) NSThread *autoDiscoveryThread;
@property (nonatomic, retain) NSDate *lastDiscoveryDate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) Controller *controller;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)buildSearchDirectories;
- (void)autoDiscoveryFinished;
- (void)loadFromHistories;
- (void)saveToHistories;
- (NSString*)historiesPlistFilepath;
- (void)findTorrentFilesAtPath:(NSString*)dir;
- (void)appendDiscoveredTorrents:(NSArray*)files;
- (void)startAutoDiscoveryThread;
- (void)autoDiscoveryThreadEnded;
- (void)autoDiscoverySearchingAtPath:(NSString*)path;
- (void)doneButtonClicked:(id)sender;
- (void)infoButtonClicked:(id)sender;

- (void)_autoDiscoveryMain;

@end
