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

@implementation PrefViewController

@synthesize tableView = fTableView;
@synthesize originalPreferences = fOriginalPreferences;
@synthesize portChecker = fPortChecker;
@synthesize indexPathToScroll = fIndexPathToScroll;
@synthesize controller = fController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Preferences";
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonClicked)];
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)];
        
        [self.navigationItem setLeftBarButtonItem:closeButton];
        [self.navigationItem setRightBarButtonItem:saveButton];
        
    }
    return self;
}

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

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
	keyboardIsShowing = YES;
	[self resizeToFit];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 2;
        case 1: return 2;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Port Listening";
        case 1: return @"Background Downloading";
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: return nil;
        case 1: return @"Enable downloading while in background through multimedia functions";
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
                case 1: return fEnableMicrophoneCell;
            }
        }
    }
    return nil;
}

- (void)switchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)portCheckButtonClicked
{
	if ([self.navigationItem.rightBarButtonItem isEnabled]) {
		[[[UIAlertView alloc] initWithTitle:@"Failure" message:@"Please save before performing a port check. " delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
	}
	else {
		self.portChecker = [[PortChecker alloc] initForPort:[self.originalPreferences integerForKey:@"BindPort"] delay:NO withDelegate:self];
		[fPortCheckActivityIndicator startAnimating];
		[fCheckPortButton setEnabled:NO];
	}
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

- (void)saveButtonClicked
{
	Controller *controller = (Controller*)[[UIApplication sharedApplication] delegate];
    tr_session *fHandle = [controller rawSession];
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([fAutoPortMapSwitch isOn] != [self.originalPreferences boolForKey:@"NatTraversal"]) {
        [fDefaults setBool:[fAutoPortMapSwitch isOn] forKey:@"NatTraversal"];
        tr_sessionSetPortForwardingEnabled(fHandle, [fAutoPortMapSwitch isOn]);
    }
    
    if([fEnableBackgroundDownloadingSwitch isOn] != [self.originalPreferences boolForKey:@"BackgroundDownloading"])
    {
        [fDefaults setBool:[fEnableBackgroundDownloadingSwitch isOn] forKey:@"BackgroundDownloading"];
    }
    
    if([fEnableMicrophoneSwitch isOn] != [self.originalPreferences boolForKey:@"UseMicrophone"])
    {
        [fDefaults setBool:[fEnableMicrophoneSwitch isOn] forKey:@"UseMicrophone"];
    }
    
	[fDefaults synchronize]; 
    
    [self performSelector:@selector(loadPreferences) withObject:nil afterDelay:0.0f];
}

- (void)closeButtonClicked
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
	[fCheckPortButton addTarget:self action:@selector(portCheckButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	
    [self loadPreferences];

}

- (void)loadPreferences
{
    NSMutableDictionary *_originalPref = [NSMutableDictionary dictionary];
	NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
	[_originalPref setBool:[fDefaults boolForKey:@"NatTraversal"] forKey:@"NatTraversal"];
	[_originalPref setInteger:[fDefaults integerForKey:@"BindPort"] forKey:@"BindPort"];
    [_originalPref setBool:[fDefaults boolForKey:@"BackgroundDownloading"] forKey:@"BackgroundDownloading"];
    [_originalPref setBool:[fDefaults boolForKey:@"UseMicrophone"] forKey:@"UseMicrophone"];
	self.originalPreferences = [NSDictionary dictionaryWithDictionary:_originalPref];
	
	[fAutoPortMapSwitch setOn:[self.originalPreferences boolForKey:@"NatTraversal"]];
	[fBindPortTextField setText:[NSString stringWithFormat:@"%li", (long)[self.originalPreferences integerForKey:@"BindPort"]]];
    [fEnableBackgroundDownloadingSwitch setOn:[self.originalPreferences boolForKey:@"BackgroundDownloading"]];
    [fEnableMicrophoneSwitch setOn:[self.originalPreferences boolForKey:@"UseMicrophone"]];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (IBAction)checkPortButtonClicked:(id)sender
{
    int bind_port = [[fBindPortTextField text] intValue];
    if (bind_port != [self.originalPreferences integerForKey:@"BindPort"]) {
        [[[UIAlertView alloc] initWithTitle:@"Cannot check port" message:@"Bind port may have been modified. Please save before port test." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (IBAction)enableBackgroundDownloadSwitchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    NSNumber *value = [NSNumber numberWithBool:fEnableBackgroundDownloadingSwitch.on];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioPrefChanged" object:value];
}

- (IBAction)enableMicrophoneSwitchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    // display alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This feature is beta, it stores microphone data to RAM, which may increase CPU and RAM usage" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    
    NSNumber *value = [NSNumber numberWithBool:fEnableMicrophoneSwitch.on];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UseMicrophone" object:value];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
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
