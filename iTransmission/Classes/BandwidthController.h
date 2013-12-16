//
//  BandwidthController.h
//  iTransmission
//
//  Created by Mike Chen on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatisticsViewController.h"

@class Torrent;
@interface BandwidthController : StatisticsViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	Torrent *fTorrent;
	UITableView *fTableView;
	BOOL _visible;
    BOOL keyboardIsShowing;
    NSIndexPath *fIndexPathToScroll;
    CGRect keyboardBounds;

    IBOutlet UILabel *fMaximumConnectionsLabel;
    IBOutlet UITableViewCell *fMaximumConnectionsLabelCell;
    
    IBOutlet UITableViewCell *fMaximumConnectionsSliderCell;
    IBOutlet UISlider *fMaximumConnectionsSlider;
    
    IBOutlet UITableViewCell *fConnectionsPerTorrentLabelCell;
    IBOutlet UILabel *fConnectionsPerTorrentLabel;
    
    IBOutlet UITableViewCell *fConnectionsPerTorrentSliderCell;
    IBOutlet UISlider *fConnectionsPerTorrentSlider;
    
    IBOutlet UITableViewCell *fDownloadSpeedLimitCell;
    IBOutlet UITextField *fDownloadSpeedLimitField;
    
    IBOutlet UITableViewCell *fUploadSpeedLimitCell;
    IBOutlet UITextField *fUploadSpeedLimitField;
    
    IBOutlet UITableViewCell *fUploadSpeedLimitEnabledCell;
    IBOutlet UISwitch *fUploadSpeedLimitEnabledSwitch;
    
    IBOutlet UITableViewCell *fDownloadSpeedLimitEnabledCell;
    IBOutlet UISwitch *fDownloadSpeedLimitEnabledSwitch;
    
    IBOutlet UITableViewCell *fOverrideSpeedLimitsCell;
    IBOutlet UISwitch *fOverrideSpeedLimitSwitch;
}
@property (nonatomic, assign) Torrent *torrent;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPathToScroll;

- (IBAction)maximumConnectionsSliderValueChanged:(id)sender;
- (IBAction)connectionsPerTorrentSliderValueChanged:(id)sender;
- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)overrideGlobalLimitsEnabledValueChanged:(id)sender;

- (void)enableOrDisableLimitCells;
- (void)hide;
- (void)keyboardDoneButton:(id)sender;
- (void)resizeToFit;

- (void)keyboardWillHide:(NSNotification*)notif;
- (void)keyboardDidHide:(NSNotification*)notif;
- (void)keyboardWillShow:(NSNotification*)notif;
- (void)keyboardDidShow:(NSNotification*)notif;
@end
