//
//  TackersController.h
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import <Foundation/Foundation.h>
#import "TrackerCell.h"
#import "Torrent.h"
#import "StatisticsViewController.h"
#import "TrackerNode.h"
#import "NSStringAdditions.h"

@class Torrent, TrackerCell;

@interface TrackersViewController : StatisticsViewController <UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate> {
    Torrent *fTorrent;
    UITableView *fTableView;
    UIDocumentInteractionController *_docController;
    NSMutableArray *Trackers;
}
@property (nonatomic, readonly) Torrent *torrent;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIDocumentInteractionController *docController;

- (id)initWithTorrent:(Torrent*)t;
- (void)updateCell:(TrackerCell*)cell;



@end
