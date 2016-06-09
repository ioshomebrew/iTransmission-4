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
    
    IBOutlet UITableViewCell *fAutoPortMapCell;
    IBOutlet UITableViewCell *fBindPortCell;
    IBOutlet UITableViewCell *fBackgroundDownloadingCell;
    IBOutlet UITableViewCell *fEnableMicrophoneCell;
    IBOutlet UIButton *fCheckPortButton;
    
	IBOutlet UISwitch *fAutoPortMapSwitch;
    IBOutlet UISwitch *fEnableBackgroundDownloadingSwitch;
    IBOutlet UISwitch *fEnableMicrophoneSwitch;
	IBOutlet UITextField *fBindPortTextField;
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

- (IBAction)switchChanged:(id)sender;
- (IBAction)checkPortButtonClicked:(id)sender;
- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender;
- (IBAction)enableMicrophoneSwitchChanged:(id)sender;

@end
