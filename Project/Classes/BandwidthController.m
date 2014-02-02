//
//  BandwidthController.m
//  iTransmission
//
//  Created by Mike Chen on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BandwidthController.h"
#import "Torrent.h"
#import "Controller.h"
#include <math.h>  // roundtol()

@implementation BandwidthController
@synthesize torrent = fTorrent;
@synthesize visible = _visible;
@synthesize tableView = fTableView;
@synthesize indexPathToScroll = fIndexPathToScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Global Bandwidth";
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hide)] autorelease];
        self.navigationItem.rightBarButtonItem = doneButton;
        
	}
	return self;
}

- (void)setTorrent:(Torrent *)torrent
{
    fTorrent = torrent;
    if (torrent) {
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"Bandwidth";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.torrent) return 2;
    else return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (self.torrent)
                return 2;
            else 
                return 4;
            break;
        case 1:
            if (self.torrent) return 3;
            else return 2;
        case 2:
            return 2;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return fMaximumConnectionsLabelCell;
                case 1:
                    return fMaximumConnectionsSliderCell;
                case 2:
                    return fConnectionsPerTorrentLabelCell;
                case 3:
                    return fConnectionsPerTorrentSliderCell;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                    if (self.torrent) return fUploadSpeedLimitCell;
                    else return fUploadSpeedLimitCell;    
                case 0:
                    if (self.torrent) return fOverrideSpeedLimitsCell;
                    else return fUploadSpeedLimitEnabledCell;
                case 2:
                    return fDownloadSpeedLimitCell;
                default:
                    break;
            }
        case 2:
            switch (indexPath.row) {
                case 1:
                    return fDownloadSpeedLimitCell;     
                case 0:
                    return fDownloadSpeedLimitEnabledCell;
                default:
                    break;
            }
        default:
            break;
    }
    assert(false);
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Connections";
            break;
        case 1:
            if (self.torrent) return @"Speed Limits";
            else return @"Upload";
        case 2:
            return @"Download";
        default:
            break;
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return @"Caution! Too many connections will make your device unstable.";
    if (section == 1)
        return @"30KB/s is recommended for upload.";
    return nil;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)maximumConnectionsSliderValueChanged:(id)sender
{
    int intValue = round([fMaximumConnectionsSlider value]);
    [fMaximumConnectionsLabel setText:[NSString stringWithFormat:@"%d", intValue]];
    if (self.torrent) {
        [self.torrent setMaxPeerConnect:intValue];
    }
    else {
        [self.controller setGlobalMaximumConnections:intValue];
    }
}

- (IBAction)connectionsPerTorrentSliderValueChanged:(id)sender
{
    assert(self.torrent == nil);
    int intValue = round([fConnectionsPerTorrentSlider value]);
    [fConnectionsPerTorrentLabel setText:[NSString stringWithFormat:@"%d", intValue]];
    [self.controller setConnectionsPerTorrent:intValue];
}

- (void)overrideGlobalLimitsEnabledValueChanged:(id)sender
{
    assert(self.torrent);
    BOOL enabled = [fOverrideSpeedLimitSwitch isOn];
    [self.torrent setUseGlobalSpeedLimit:!enabled];
    [self enableOrDisableLimitCells];
}

- (void)uploadSpeedLimitEnabledValueChanged:(id)sender
{
    BOOL enabled = [fUploadSpeedLimitEnabledSwitch isOn];
    if (self.torrent) {
    }
    else {
        [self.controller setGlobalUploadSpeedLimitEnabled:enabled];
    }
}

- (void)downloadSpeedLimitEnabledValueChanged:(id)sender
{
    BOOL enabled = [fDownloadSpeedLimitEnabledSwitch isOn];
    if (self.torrent) {
    }
    else {
        [self.controller setGlobalDownloadSpeedLimitEnabled:enabled];
    }
}

- (void)hide
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.torrent) {
        [fMaximumConnectionsLabel setText:[NSString stringWithFormat:@"%d", [self.torrent maxPeerConnect]]];
        [fMaximumConnectionsSlider setValue:[self.torrent maxPeerConnect]];
        [fOverrideSpeedLimitSwitch setOn:![self.torrent usesGlobalSpeedLimit]];
        [fUploadSpeedLimitField setText:[NSString stringWithFormat:@"%d", [self.torrent speedLimit:YES]]];
        [fDownloadSpeedLimitField setText:[NSString stringWithFormat:@"%d", [self.torrent speedLimit:NO]]];
        [self enableOrDisableLimitCells];
    }
    else {
        [fConnectionsPerTorrentSlider setValue:[self.controller connectionsPerTorrent]];
        [fConnectionsPerTorrentLabel setText:[NSString stringWithFormat:@"%d", [self.controller connectionsPerTorrent]]];
        [fMaximumConnectionsSlider setValue:[self.controller globalMaximumConnections]];
        [fMaximumConnectionsLabel setText:[NSString stringWithFormat:@"%d", [self.controller globalMaximumConnections]]];
        [fUploadSpeedLimitField setText:[NSString stringWithFormat:@"%d", [self.controller globalUploadSpeedLimit]]];
        [fDownloadSpeedLimitField setText:[NSString stringWithFormat:@"%d", [self.controller globalDownloadSpeedLimit]]];
        [fUploadSpeedLimitEnabledSwitch setOn:[self.controller globalUploadSpeedLimitEnabled]];
        [fDownloadSpeedLimitEnabledSwitch setOn:[self.controller globalDownloadSpeedLimitEnabled]];

    }
}

- (void)enableOrDisableLimitCells
{
    if (self.torrent) {
        if ([self.torrent usesGlobalSpeedLimit]) {
            [fUploadSpeedLimitField setEnabled:NO];
            [fDownloadSpeedLimitField setEnabled:NO];
        }
        else {
            [fUploadSpeedLimitField setEnabled:YES];
            [fDownloadSpeedLimitField setEnabled:YES];
        }
    }
}

- (void)keyboardDoneButton:(id)sender
{
    if ([fDownloadSpeedLimitField isEditing])
        [fDownloadSpeedLimitField resignFirstResponder];
    if ([fUploadSpeedLimitField isEditing])
        [fUploadSpeedLimitField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
	keyboardIsShowing = YES;
	[self resizeToFit];
}

- (void)resizeToFit {
	// Needs adjustment for portrait orientation!
	CGRect applicationFrame = self.view.frame;
	CGRect frame = self.tableView.frame;
    if (self.torrent)
        frame.size.height = applicationFrame.size.height + 20;
    else 
        frame.size.height = applicationFrame.size.height - 20;
    
	if (keyboardIsShowing)
		frame.size.height -= keyboardBounds.size.height;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	self.tableView.frame = frame;
	[UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    if (self.indexPathToScroll)
        [self.tableView scrollToRowAtIndexPath:self.indexPathToScroll atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    self.indexPathToScroll = nil;
}

- (void)keyboardWillHide:(NSNotification *)note {
	keyboardIsShowing = NO;
	keyboardBounds = CGRectMake(0, 0, 0, 0);
	[self resizeToFit];
}

- (void)keyboardDidShow:(NSNotification *)notif
{
    if (self.indexPathToScroll)
        [self.tableView scrollToRowAtIndexPath:self.indexPathToScroll atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    self.indexPathToScroll = nil;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(keyboardDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard found, add the button
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:doneButton];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIView *cellContentView = [textField superview];
    UITableViewCell *cell = (UITableViewCell*)[cellContentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.indexPathToScroll = indexPath;
    [self.tableView scrollToRowAtIndexPath:self.indexPathToScroll atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == fUploadSpeedLimitField) {
        int limit = [[textField text] intValue];
        if (self.torrent) {
            [self.torrent setSpeedLimit:limit upload:YES];
            [self enableOrDisableLimitCells];
        }
        else {
            [self.controller setGlobalUploadSpeedLimit:limit];
        }
    }
    if (textField == fDownloadSpeedLimitField) {
        int limit = [[textField text] intValue];
        if (self.torrent) {
            [self.torrent setSpeedLimit:limit upload:NO];
            [self enableOrDisableLimitCells];
        }
        else {
            [self.controller setGlobalDownloadSpeedLimit:limit];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];      
    [self.navigationController setToolbarHidden:YES animated:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
	self.torrent = nil;
    [fMaximumConnectionsLabelCell release];
    [fMaximumConnectionsSlider release];
    [fMaximumConnectionsSliderCell release];
    [fMaximumConnectionsLabel release];
    [fConnectionsPerTorrentLabel release];
    [fConnectionsPerTorrentLabelCell release];
    [fConnectionsPerTorrentSlider release];
    [fConnectionsPerTorrentSliderCell release];
    [fUploadSpeedLimitField release];
    [fUploadSpeedLimitCell release];
    [fDownloadSpeedLimitField release];
    [fDownloadSpeedLimitCell release];
    [fDownloadSpeedLimitEnabledSwitch release];
    [fDownloadSpeedLimitEnabledCell release];
    [fUploadSpeedLimitEnabledSwitch release];
    [fUploadSpeedLimitEnabledCell release];
    [fOverrideSpeedLimitSwitch release];
    [fOverrideSpeedLimitsCell release];
    self.tableView = nil;
    self.indexPathToScroll = nil;
	[super dealloc];
}

@end
