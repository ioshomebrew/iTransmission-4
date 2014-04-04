//
//  PrefViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class GradientButton;
@class PortChecker;
@class Controller;
@interface PrefViewController :UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UITableView *fTableView;
    //Controller *fController;
    
    IBOutlet UITableViewCell *fEnableRPCCell;
    IBOutlet UITableViewCell *fRPCUsernameCell;
    IBOutlet UITableViewCell *fRPCPasswordCell;
    IBOutlet UITableViewCell *fRPCPortCell;
    IBOutlet UITableViewCell *fUseCellularNetworkCell;
    IBOutlet UITableViewCell *fUseWiFiCell;
    IBOutlet UITableViewCell *fAutoPortMapCell;
    IBOutlet UITableViewCell *fRPCRequireAuthCell;
    IBOutlet UITableViewCell *fBindPortCell;
    IBOutlet UITableViewCell *fEnableLoggingCell;
    IBOutlet UITableViewCell *fBackgroundDownloadingCell;
    IBOutlet UITableViewCell *fEnableMicrophoneCell;
    IBOutlet UIButton *fCheckPortButton;
    
	IBOutlet UISwitch *fEnableRPCSwitch;
	IBOutlet UISwitch *fRPCRequireAuthSwitch;
	IBOutlet UISwitch *fUseWiFiSwitch;
	IBOutlet UISwitch *fUseCellularNetworkSwitch;
	IBOutlet UISwitch *fAutoPortMapSwitch;
    IBOutlet UISwitch *fEnableLoggingSwitch;
    IBOutlet UISwitch *fEnableBackgroundDownloadingSwitch;
    IBOutlet UISwitch *fEnableMicrophoneSwitch;
	IBOutlet UITextField *fBindPortTextField;
	IBOutlet UITextField *fRPCUsernameTextField;
	IBOutlet UITextField *fRPCPasswordTextField;
	IBOutlet UITextField *fRPCPortTextField;
	IBOutlet UIActivityIndicatorView *fPortCheckActivityIndicator;
    
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
- (void)saveButtonClicked;
- (void)portCheckButtonClicked;
- (void)keyboardDoneButton:(id)sender;

- (void)keyboardWillHide:(NSNotification*)notif;
- (void)keyboardDidHide:(NSNotification*)notif;
- (void)keyboardWillShow:(NSNotification*)notif;
- (void)keyboardDidShow:(NSNotification*)notif;

- (void)loadPreferences;

- (IBAction)enableRPCSwitchChanged:(id)sender;
- (IBAction)RPCRequireAuthSwitchChanged:(id)sender;
- (IBAction)UseWiFiSwitchChanged:(id)sender;
- (IBAction)switchChanged:(id)sender;
- (IBAction)checkPortButtonClicked:(id)sender;
- (IBAction)enableLoggingSwitchChanged:(id)sender;
- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender;
- (IBAction)enableMicrophoneSwitchChanged:(id)sender;

@end
