//
//  PrefViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Controller.h"

@class GradientButton;
@class PortChecker;
@class Controller;
@interface PrefViewController :UITableViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UITableView *fTableView;
    
    IBOutlet UITableViewCell *fAutoPortMapCell;
    IBOutlet UITableViewCell *fBindPortCell;
    IBOutlet UITableViewCell *fBackgroundDownloadingCell;
    IBOutlet UIButton *fCheckPortButton;
    
	IBOutlet UISwitch *fAutoPortMapSwitch;
    IBOutlet UISwitch *fEnableBackgroundDownloadingSwitch;
	IBOutlet UITextField *fBindPortTextField;
	IBOutlet UIActivityIndicatorView *fPortCheckActivityIndicator;
    
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
    
    UIColor *fTextFieldTextColor;
    
    BOOL keyboardIsShowing;
    CGRect keyboardBounds;
	
	NSDictionary *fOriginalPreferences;
	PortChecker *fPortChecker;
    NSIndexPath *fIndexPathToScroll;

}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) PortChecker *portChecker;
@property (nonatomic, retain) NSDictionary *originalPreferences;
@property (nonatomic, retain) NSIndexPath *indexPathToScroll;
@property (nonatomic, assign) Controller *controller;

- (void)closeButtonClicked;
- (void)portCheckButtonClicked;
- (void)keyboardDoneButton:(id)sender;

- (void)loadPreferences;

- (IBAction)switchChanged:(id)sender;
- (IBAction)checkPortButtonClicked:(id)sender;
- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender;

- (IBAction)maximumConnectionsSliderValueChanged:(id)sender;
- (IBAction)connectionsPerTorrentSliderValueChanged:(id)sender;
- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)overrideGlobalLimitsEnabledValueChanged:(id)sender;


@end
