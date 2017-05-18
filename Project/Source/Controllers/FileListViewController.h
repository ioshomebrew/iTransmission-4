//
//  FileListViewController.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <AdColony/AdColony.h>
#import "IJKMoviePlayerViewController.h"
#import "CheckboxControl.h"
#import "AudioPlayer.h"
@class IJKMediaControl;

typedef enum FileType
{
    TYPE_VIDEO,
    TYPE_AUDIO,
    TYPE_PICTURE,
    TYPE_TXT,
    TYPE_PDF,
    TYPE_NULL,
} FileType;

@class Torrent, FileListCell;
@interface FileListViewController : UIViewController <CheckboxControlDelegate,UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, AdColonyAdDelegate>
{
    Torrent *fTorrent;
    UITableView *fTableView;
    UIDocumentInteractionController *_docController;
}
@property (nonatomic, readonly) Torrent *torrent;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet GADBannerView *bannerView;
@property (nonatomic, retain) UIDocumentInteractionController *docController;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSIndexPath *actionIndexPath;

- (void)initWithTorrent:(Torrent*)t;
- (void)updateCell:(FileListCell*)cell;
- (FileType)fileType:(NSString*)url;
- (void)playVideo:(NSString*)url;
- (void)playAudio:(NSString*)url;
- (void)viewDocument:(NSString*)url;

@property(nonatomic,strong) IBOutlet IJKMediaControl *mediaControl;

@end
