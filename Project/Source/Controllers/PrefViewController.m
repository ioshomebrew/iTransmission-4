//
//  PrefViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PrefViewController.h"
#import "NSDictionaryAdditions.h"
#import "Controller.h"
#import "PortChecker.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation PrefViewController

@synthesize tableView = fTableView;
@synthesize originalPreferences = fOriginalPreferences;
@synthesize portChecker = fPortChecker;
@synthesize indexPathToScroll = fIndexPathToScroll;
@synthesize controller = fController;
@synthesize bannerView;

- (void)resizeToFit {
	// Needs adjustment for portrait orientation!
	CGRect applicationFrame = self.view.frame;
	CGRect frame = self.tableView.frame;
	frame.size.height = applicationFrame.size.height;
    
	if (keyboardIsShowing)
		frame.size.height -= keyboardBounds.size.height;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	self.tableView.frame = frame;
	[UIView commitAnimations];
}

- (void)keyboardDoneButton:(id)sender
{
    if ([fBindPortTextField isEditing])
        [fBindPortTextField resignFirstResponder];
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
    
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if (textField == fBindPortTextField) {
        NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([new length] == 0) return YES;
        NSScanner *scanner = [NSScanner scannerWithString:new];
        int value;
        if ([scanner scanInt:&value] == NO) return NO;
        if ([scanner isAtEnd] == NO) return NO;
        if (value == INT_MAX || value == INT_MIN || value > 65535 || value < 1) {
            return NO;
        }
        else return YES;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 2;
        case 1: return 1;
            case 2: return 2;
            case 3: return 2;
            case 4: return 2;
        case 5: return 1;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Port Listening";
        case 1: return @"Background Downloading";
        case 2: return @"Connections";
            case 3: return @"Upload";
            case 4: return @"Download";
        case 5: return @"Share";
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: return nil;
        case 1: return @"Enable downloading while in background through multimedia functions";
        case 2: return @"Caution! Too many connections will make your device unstable.";
        case 3: return @"30KB/s is recommended for upload.";
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: return fBindPortCell;
                case 1: return fAutoPortMapCell;
            }
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0: return fBackgroundDownloadingCell;
            }
        }
        case 2:
        {
            switch (indexPath.row) {
                case 0: return fMaximumConnectionsLabelCell;
                case 1: return fConnectionsPerTorrentLabelCell;
            }
        }
        case 3:
        {
            switch (indexPath.row) {
                case 0: return fUploadSpeedLimitEnabledCell;
                case 1: return fUploadSpeedLimitCell;
                
            }
        }
        case 4:
        {
            switch (indexPath.row) {
                case 0: return fDownloadSpeedLimitEnabledCell;
                case 1: return fDownloadSpeedLimitCell;
            }
        }
        case 5:
        {
            switch (indexPath.row) {
                case 0: return fShareCell;
            }
        }
    }
    return nil;
}

- (void)portCheckButtonClicked
{
    self.portChecker = [[PortChecker alloc] initForPort:[self.originalPreferences integerForKey:@"BindPort"] delay:NO withDelegate:self];
    [fPortCheckActivityIndicator startAnimating];
    [fCheckPortButton setEnabled:NO];
}

- (void)portCheckerDidFinishProbing:(PortChecker*)c
{
	[fCheckPortButton setEnabled:YES];
	NSString *msg;
	if ([c status] == PORT_STATUS_OPEN) {
		msg = [NSString stringWithFormat:@"Congratulations. Your port %li is open!", (long)[c portToCheck]];
	}
	if ([c status] == PORT_STATUS_ERROR) {
		msg = @"Failed to perform port check.";
	}
	if ([c status] == PORT_STATUS_CLOSED) {
		msg = [NSString stringWithFormat:@"Oh bad. Your port %li is not accessable from outside.", (long)[c portToCheck]];
	}
	
	[fPortCheckActivityIndicator stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Port check" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
}

- (void)closeButtonClicked
{
    // go back to main screen
    UINavigationController *navigationController = (UINavigationController *)self.sideMenu.rootViewController;
    [navigationController setViewControllers:@[self.torrentView]];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.controller setGlobalUploadSpeedLimit:[[fUploadSpeedLimitField text] intValue]];
    [self.controller setGlobalDownloadSpeedLimit:[[fDownloadSpeedLimitField text] intValue]];
    tr_session *fHandle = [self.controller rawSession];
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([fAutoPortMapSwitch isOn] != [self.originalPreferences boolForKey:@"NatTraversal"]) {
        [fDefaults setBool:[fAutoPortMapSwitch isOn] forKey:@"NatTraversal"];
        tr_sessionSetPortForwardingEnabled(fHandle, [fAutoPortMapSwitch isOn]);
    }
    
    if([fEnableBackgroundDownloadingSwitch isOn] != [self.originalPreferences boolForKey:@"BackgroundDownloading"])
    {
        [fDefaults setBool:[fEnableBackgroundDownloadingSwitch isOn] forKey:@"BackgroundDownloading"];
    }
    
    // set bind port
    [fDefaults setInteger:[fBindPortTextField text].intValue forKey:@"BindPort"];
    tr_sessionSetPeerPort(fHandle, [fBindPortTextField text].intValue);
    
    [fDefaults synchronize];
    
    int limit = [[fUploadSpeedLimitField text] intValue];
    [self.controller setGlobalUploadSpeedLimit:limit];
    
    limit = [[fDownloadSpeedLimitField text] intValue];
    [self.controller setGlobalDownloadSpeedLimit:limit];
    
    [self performSelector:@selector(loadPreferences) withObject:nil afterDelay:0.0f];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init admob
    self.bannerView.adUnitID = @"ca-app-pub-5972525945446192/8130606866";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    [self.bannerView loadRequest:request];
    
    self.tableView.allowsSelection = NO;
	[fCheckPortButton addTarget:self action:@selector(portCheckButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	
    self.controller = (Controller*)[[UIApplication sharedApplication] delegate];
    
    [fConnectionsPerTorrentTextField setText:[NSString stringWithFormat:@"%ld", (long)[self.controller connectionsPerTorrent]]];
    [fMaximumConnectionsTextField setText:[NSString stringWithFormat:@"%ld", (long)[self.controller globalMaximumConnections]]];
    [fUploadSpeedLimitField setText:[NSString stringWithFormat:@"%ld", (long)[self.controller globalUploadSpeedLimit]]];
    [fDownloadSpeedLimitField setText:[NSString stringWithFormat:@"%ld", (long)[self.controller globalDownloadSpeedLimit]]];
    [fUploadSpeedLimitEnabledSwitch setOn:[self.controller globalUploadSpeedLimitEnabled]];
    [fDownloadSpeedLimitEnabledSwitch setOn:[self.controller globalDownloadSpeedLimitEnabled]];
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    [keyboardDoneButtonView sizeToFit];
    
    fBindPortTextField.delegate = self;
    fUploadSpeedLimitField.delegate = self;
    fDownloadSpeedLimitField.delegate = self;
    fConnectionsPerTorrentTextField.delegate = self;
    fMaximumConnectionsTextField.delegate = self;
    fBindPortTextField.inputAccessoryView = keyboardDoneButtonView;
    fUploadSpeedLimitField.inputAccessoryView = keyboardDoneButtonView;
    fDownloadSpeedLimitField.inputAccessoryView = keyboardDoneButtonView;
    fConnectionsPerTorrentTextField.inputAccessoryView = keyboardDoneButtonView;
    fMaximumConnectionsTextField.inputAccessoryView = keyboardDoneButtonView;
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self loadPreferences];

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return UITableViewAutomaticDimension;
}

- (void)loadPreferences
{
    NSMutableDictionary *_originalPref = [NSMutableDictionary dictionary];
	NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
	[_originalPref setBool:[fDefaults boolForKey:@"NatTraversal"] forKey:@"NatTraversal"];
	[_originalPref setInteger:[fDefaults integerForKey:@"BindPort"] forKey:@"BindPort"];
    [_originalPref setBool:[fDefaults boolForKey:@"BackgroundDownloading"] forKey:@"BackgroundDownloading"];
	self.originalPreferences = [NSDictionary dictionaryWithDictionary:_originalPref];
	
	[fAutoPortMapSwitch setOn:[self.originalPreferences boolForKey:@"NatTraversal"]];
	[fBindPortTextField setText:[NSString stringWithFormat:@"%li", (long)[self.originalPreferences integerForKey:@"BindPort"]]];
    [fEnableBackgroundDownloadingSwitch setOn:[self.originalPreferences boolForKey:@"BackgroundDownloading"]];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (IBAction)checkPortButtonClicked:(id)sender
{
}

- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    NSNumber *value = [NSNumber numberWithBool:fEnableBackgroundDownloadingSwitch.on];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPrefChanged" object:value];
}

- (IBAction)uploadSpeedLimitEnabledValueChanged:(id)sender
{
    BOOL enabled = [fUploadSpeedLimitEnabledSwitch isOn];
    [self.controller setGlobalUploadSpeedLimitEnabled:enabled];
}

- (IBAction)downloadSpeedLimitEnabledValueChanged:(id)sender
{
    BOOL enabled = [fDownloadSpeedLimitEnabledSwitch isOn];
    [self.controller setGlobalDownloadSpeedLimitEnabled:enabled];
}

- (IBAction)connectionsPerTorrentChanged:(id)sender
{
    int intValue = [[fConnectionsPerTorrentTextField text] intValue];
    [self.controller setConnectionsPerTorrent:intValue];
}

- (IBAction)maximumConnectionsPerTorrentChanged:(id)sender
{
    int intValue = [[fMaximumConnectionsTextField text] intValue];
    [self.controller setConnectionsPerTorrent:intValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)doneClicked:(id)sender
{
    [fBindPortTextField resignFirstResponder];
    [fUploadSpeedLimitField resignFirstResponder];
    [fDownloadSpeedLimitField resignFirstResponder];
    
    [self closeButtonClicked];
}

- (IBAction)facebookShare:(id)sender
{
    FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString: @"https://github.com/ioshomebrew/iTransmission-4"];
    content.contentTitle = @"Download iTransmission";
    content.contentDescription = @"iTransmission is a bittorrent client for iOS based on libtransmission";
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
        dialog.mode = FBSDKShareDialogModeNative;
    }
    else {
        dialog.mode = FBSDKShareDialogModeBrowser; //or FBSDKShareDialogModeAutomatic
    }
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.fromViewController = self;
    [dialog show];
}

- (IBAction)tweet:(id)sender
{
    // log into twitter
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    // tweet
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:@"Check out iTransmission https://github.com/ioshomebrew/iTransmission-4"];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[self.portChecker cancelProbe];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
	[self.portChecker cancelProbe];
}


@end
