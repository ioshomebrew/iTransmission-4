//
//  FileListViewController.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "IJKMoviePlayerViewController.h"
#import "CheckboxControl.h"
@class IJKMediaControl;

@class Torrent, FileListCell;
@interface FileListViewController : UIViewController <CheckboxControlDelegate,UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
{
    Torrent *fTorrent;
    UITableView *fTableView;
    UIDocumentInteractionController *_docController;
}
@property (nonatomic, readonly) Torrent *torrent;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIDocumentInteractionController *docController;
@property (nonatomic, retain) NSTimer *updateTimer;

- (id)initWithTorrent:(Torrent*)t;
- (void)updateCell:(FileListCell*)cell;
- (void)playVideo:(NSString*)url;
- (void)playAudio:(NSString*)url;

@property(nonatomic,strong) IBOutlet IJKMediaControl *mediaControl;

@end
