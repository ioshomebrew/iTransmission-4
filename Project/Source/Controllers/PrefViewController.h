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
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterKit/TwitterKit.h>

@class GradientButton;
@class PortChecker;
@class Controller;
@interface PrefViewController :UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FBSDKSharingDelegate> {
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
    IBOutlet UITextField *fMaximumConnectionsTextField;
    
    IBOutlet UITableViewCell *fConnectionsPerTorrentLabelCell;
    IBOutlet UILabel *fConnectionsPerTorrentLabel;
    IBOutlet UITextField *fConnectionsPerTorrentTextField;
    
    IBOutlet UITableViewCell *fDownloadSpeedLimitCell;
    IBOutlet UITextField *fDownloadSpeedLimitField;
    
    IBOutlet UITableViewCell *fUploadSpeedLimitCell;
    IBOutlet UITextField *fUploadSpeedLimitField;
    
    IBOutlet UITableViewCell *fUploadSpeedLimitEnabledCell;
    IBOutlet UISwitch *fUploadSpeedLimitEnabledSwitch;
    
    IBOutlet UITableViewCell *fDownloadSpeedLimitEnabledCell;
    IBOutlet UISwitch *fDownloadSpeedLimitEnabledSwitch;
    
    IBOutlet UITableViewCell *fShareCell;
    
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
@property (nonatomic, retain) IBOutlet GADBannerView *bannerView;
@property (nonatomic, strong) TorrentViewController *torrentView;
@property (nonatomic, strong) SideMenuController *sideMenu;

- (void)closeButtonClicked;
- (void)portCheckButtonClicked;
- (void)keyboardDoneButton:(id)sender;

- (void)loadPreferences;

- (IBAction)checkPortButtonClicked:(id)sender;
- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender;

- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender;
- (IBAction)connectionsPerTorrentChanged:(id)sender;
- (IBAction)maximumConnectionsPerTorrentChanged:(id)sender;

- (IBAction)facebookShare:(id)sender;
- (IBAction)tweet:(id)sender;

@end
