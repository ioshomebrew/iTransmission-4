//
//  PrefViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Insomnia.h"
#import "PrefViewController.h"
#import "GradientButton.h"
#import "NSDictionaryAdditions.h"
#import "Controller.h"
#import "PortChecker.h"

@implementation PrefViewController

@synthesize tableView = fTableView;
@synthesize originalPreferences = fOriginalPreferences;
@synthesize portChecker = fPortChecker;
@synthesize insomnia = fInsomnia;
@synthesize indexPathToScroll = fIndexPathToScroll;
@synthesize controller = fController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Preferences";
        
        UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonClicked)] autorelease];
        UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked)] autorelease];
        
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
    /* 
     IBOutlet UITextField *fBindPortTextField;
     IBOutlet UITextField *fRPCUsernameTextField;
     IBOutlet UITextField *fRPCPasswordTextField;
     IBOutlet UITextField *fRPCPortTextField;
     */
    if ([fBindPortTextField isEditing])
        [fBindPortTextField resignFirstResponder];
    if ([fRPCPasswordTextField isEditing])
        [fRPCPasswordTextField resignFirstResponder];
    if ([fRPCUsernameTextField isEditing])
        [fRPCUsernameTextField resignFirstResponder];
    if ([fRPCPortTextField isEditing])
        [fRPCPortTextField resignFirstResponder];
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
    
    if (textField == fBindPortTextField || textField == fRPCPortTextField) {
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 5;
        case 1: return 2;
        case 2: return 2;
        case 3: return 1;
        case 4: return 1;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Web Interface";
        case 1: return @"Network Interface";
        case 2: return @"Port Listening";
        case 3: return @"Logging";
        case 4: return @"Insomnia";
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"It's always recommended to use authentication if web interface is enabled. ";
        case 1: return @"Enabling cellular network may generate significant data charges. ";
        case 2: return nil;
        case 3: return @"Only use logging for debugging. Extensive loggings will shorten both battery and Nand life. Saved logs will be available in iTunes.";
        case 4: return @"Disable sleep mode. Never disconnects from WiFi. Consumes Power. Use when charger is plugged in.";
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: return fEnableRPCCell;
                case 1: return fRPCRequireAuthCell;
                case 2: return fRPCUsernameCell;
                case 3: return fRPCPasswordCell;
                case 4: return fRPCPortCell;
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 0: return fUseWiFiCell;
                case 1: return fUseCellularNetworkCell;
            }
        }
        case 2: {
            switch (indexPath.row) {
                case 0: return fBindPortCell;
                case 1: return fAutoPortMapCell;
            }
        }
        case 3: {
            switch (indexPath.row) {
                case 0: return fEnableLoggingCell;
            }
        }
        case 4: {
            switch (indexPath.row) {
                case 0: return fInsomniaCell;
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
		[[[[UIAlertView alloc] initWithTitle:@"Failure" message:@"Please save before performing a port check. " delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
	}
	else {
		self.portChecker = [[[PortChecker alloc] initForPort:[self.originalPreferences integerForKey:@"BindPort"] delay:NO withDelegate:self] autorelease];
		[fPortCheckActivityIndicator startAnimating];
		[fCheckPortButton setEnabled:NO];
	}
}

- (void)portCheckerDidFinishProbing:(PortChecker*)c
{
	[fCheckPortButton setEnabled:YES];
	NSString *msg;
	if ([c status] == PORT_STATUS_OPEN) {
		msg = [NSString stringWithFormat:@"Congratulations. Your port %i is open!", [c portToCheck]];
	}
	if ([c status] == PORT_STATUS_ERROR) {
		msg = @"Failed to perform port check.";
	}
	if ([c status] == PORT_STATUS_CLOSED) {
		msg = [NSString stringWithFormat:@"Oh bad. Your port %i is not accessable from outside.", [c portToCheck]];
	}
	
	[fPortCheckActivityIndicator stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Port check" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)saveButtonClicked
{
    
	BOOL callSetNetworkActive = NO;
	
	Controller *controller = (Controller*)[[UIApplication sharedApplication] delegate];
    tr_session *fHandle = [controller rawSession];
    NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([fEnableRPCSwitch isOn] != [self.originalPreferences boolForKey:@"RPC"]) {
        [fDefaults setBool:[fEnableRPCSwitch isOn] forKey:@"RPC"];
        tr_sessionSetRPCEnabled(fHandle, [fEnableRPCSwitch isOn]);
    }
    
    if ([fRPCRequireAuthSwitch isOn] != [self.originalPreferences boolForKey:@"RPCAuthorize"]) {
        [fDefaults setBool:[fRPCRequireAuthSwitch isOn] forKey:@"RPCAuthorize"];
        tr_sessionSetRPCPasswordEnabled(fHandle, [fRPCRequireAuthSwitch isOn]);
    }
    
    if (![[fRPCUsernameTextField text] isEqualToString:[self.originalPreferences stringForKey:@"RPCUsername"]]) {
        [fDefaults setObject:[fRPCUsernameTextField text] forKey:@"RPCUsername"];
        tr_sessionSetRPCUsername(fHandle, [[fRPCUsernameTextField text] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    // TODO: Fix password in key chain. 
//    if (![[fRPCUsernameTextField text] isEqualToString:[self.originalPreferences stringForKey:@"RPCUsername"]]) {
//        [fDefaults setObject:[fRPCUsernameTextField text] forKey:@"RPCUsername"];
//        tr_sessionSetRPCUsername(fHandle, [[fRPCUsernameTextField text] cStringUsingEncoding:NSUTF8StringEncoding]);
//    }
    
    int rpc_port = [[fRPCPortTextField text] intValue];
    if (rpc_port != [self.originalPreferences integerForKey:@"RPCPort"]) {
        if (rpc_port < 1024 || rpc_port > 65535) return;
        [fDefaults setInteger:rpc_port forKey:@"RPCPort"];
        tr_sessionSetRPCPort(fHandle, rpc_port);
    }
    
    if ([fAutoPortMapSwitch isOn] != [self.originalPreferences boolForKey:@"NatTraversal"]) {
        [fDefaults setBool:[fAutoPortMapSwitch isOn] forKey:@"NatTraversal"];
        tr_sessionSetPortForwardingEnabled(fHandle, [fAutoPortMapSwitch isOn]);
    }
    
    int bind_port = [[fBindPortTextField text] intValue];
    if (bind_port != [self.originalPreferences integerForKey:@"BindPort"]) {
        if (rpc_port < 1024 || rpc_port > 65535) return;
        [fDefaults setInteger:bind_port forKey:@"BindPort"];
        tr_sessionSetPeerPort(fHandle, bind_port);
    }
    
    if ([fUseWiFiSwitch isOn] != [self.originalPreferences boolForKey:@"UseWiFi"]) {
        [fDefaults setBool:[fUseWiFiSwitch isOn] forKey:@"UseWiFi"];
		callSetNetworkActive = YES;
    }
    
    if ([fUseCellularNetworkSwitch isOn] != [self.originalPreferences boolForKey:@"UseCellularNetwork"]) {
        [fDefaults setBool:[fUseCellularNetworkSwitch isOn] forKey:@"UseCellularNetwork"];
		callSetNetworkActive = YES;
    }
	
    if ([fInsomniaSwitch isOn] != [self.originalPreferences boolForKey:@"Insomnia"]) {
        [fDefaults setBool:[fInsomniaSwitch isOn] forKey:@"Insomnia"];
        if ([fInsomniaSwitch isOn] == YES) {
            [fInsomnia disableSleep];
        } else {
            [fInsomnia enableSleep];
        }
    }
    
	if (callSetNetworkActive)
		[controller updateNetworkStatus];
	
    [fDefaults setBool:[fEnableLoggingSwitch isOn] forKey:@"LoggingEnabled"];
    [self.controller setLoggingEnabled:[fEnableLoggingSwitch isOn]];
    
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
    [fCheckPortButton useSimpleOrangeStyle];
	[fCheckPortButton addTarget:self action:@selector(portCheckButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	
    fTextFieldTextColor = [[fRPCPortTextField textColor] retain];
    [self loadPreferences];

}

- (void)loadPreferences
{
    NSMutableDictionary *_originalPref = [NSMutableDictionary dictionary];
	NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
	[_originalPref setBool:[fDefaults boolForKey:@"RPC"] forKey:@"RPC"];
	[_originalPref setBool:[fDefaults boolForKey:@"RPCAuthorize"] forKey:@"RPCAuthorize"];
	[_originalPref setString:[fDefaults stringForKey:@"RPCUsername"] forKey:@"RPCUsername"];
	[_originalPref setInteger:[fDefaults integerForKey:@"RPCPort"] forKey:@"RPCPort"];
	[_originalPref setBool:[fDefaults boolForKey:@"NatTraversal"] forKey:@"NatTraversal"];
	[_originalPref setInteger:[fDefaults integerForKey:@"BindPort"] forKey:@"BindPort"];
	[_originalPref setBool:[fDefaults boolForKey:@"UseWiFi"] forKey:@"UseWiFi"];
	[_originalPref setBool:[fDefaults boolForKey:@"UseCellularNetwork"] forKey:@"UseCellularNetwork"];
    [_originalPref setBool:[fDefaults boolForKey:@"LoggingEnabled"] forKey:@"LoggingEnabled"];
    [_originalPref setBool:[fDefaults boolForKey:@"Insomnia"] forKey:@"Insomnia"];
	self.originalPreferences = [NSDictionary dictionaryWithDictionary:_originalPref];
	
	[fEnableRPCSwitch setOn:[self.originalPreferences boolForKey:@"RPC"]];
	[fRPCRequireAuthSwitch setOn:[self.originalPreferences boolForKey:@"RPCAuthorize"]];
	[fRPCUsernameTextField setText:[self.originalPreferences stringForKey:@"RPCUsername"]];
	[fRPCPortTextField setText:[NSString stringWithFormat:@"%i", [self.originalPreferences integerForKey:@"RPCPort"]]];
	[fAutoPortMapSwitch setOn:[self.originalPreferences boolForKey:@"NatTraversal"]];
	[fBindPortTextField setText:[NSString stringWithFormat:@"%i", [self.originalPreferences integerForKey:@"BindPort"]]];
	[fUseWiFiSwitch setOn:[self.originalPreferences boolForKey:@"UseWiFi"]];
	[fUseCellularNetworkSwitch setOn:[self.originalPreferences boolForKey:@"UseCellularNetwork"]];
    [fEnableLoggingSwitch setOn:[self.originalPreferences boolForKey:@"LoggingEnabled"]];
    [fInsomniaSwitch setOn:[self.originalPreferences boolForKey:@"Insomnia"]];
    
    [self enableRPCSwitchChanged:fEnableRPCSwitch];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (IBAction)enableRPCSwitchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

	BOOL on = [fEnableRPCSwitch isOn];
	[fRPCRequireAuthSwitch setEnabled:on];
    [fRPCPortTextField setEnabled:on];
	[self RPCRequireAuthSwitchChanged:fRPCRequireAuthSwitch];
    if (on == NO) {
        [fRPCPortTextField setTextColor:[UIColor grayColor]];
    }
    else {
        [fRPCPortTextField setTextColor:fTextFieldTextColor];
    }
}

- (IBAction)RPCRequireAuthSwitchChanged:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

	BOOL on = [fRPCRequireAuthSwitch isOn];
	[fRPCUsernameTextField setEnabled:(on && [fEnableRPCSwitch isOn])];
	[fRPCPasswordTextField setEnabled:(on && [fEnableRPCSwitch isOn])];
    if ((on && [fEnableRPCSwitch isOn]) == NO) {
        [fRPCUsernameTextField setTextColor:[UIColor grayColor]];
        [fRPCPasswordTextField setTextColor:[UIColor grayColor]];
    }
    else {
        [fRPCUsernameTextField setTextColor:fTextFieldTextColor];
        [fRPCPasswordTextField setTextColor:fTextFieldTextColor];   
    }
}

- (IBAction)UseWiFiSwitchChanged:(id)sender
{
	BOOL on = [fUseWiFiSwitch isOn];
	if (on == NO) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Disable WiFi" message:@"Disabling WiFi is strongly discouraged! Please make sure this is what you want. " delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
		[alertView show];
	}
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (IBAction)enableLoggingSwitchChanged:(id)sender
{    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (IBAction)checkPortButtonClicked:(id)sender
{
    int bind_port = [[fBindPortTextField text] intValue];
    if (bind_port != [self.originalPreferences integerForKey:@"BindPort"]) {
        [[[[UIAlertView alloc] initWithTitle:@"Cannot check port" message:@"Bind port may have been modified. Please save before port test." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
    }
}

- (IBAction)insomniaSwitchChanged:(id)sender {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
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
	self.tableView = nil;
	[self.portChecker cancelProbe];
	self.portChecker = nil;
    self.originalPreferences = nil;
    [fTextFieldTextColor release];
    [fBindPortCell release];
    [fEnableRPCCell release];
    [fRPCPortCell release];
    [fRPCPasswordCell release];
    [fRPCRequireAuthCell release];
    [fRPCUsernameCell release];
    [fUseWiFiCell release];
    [fUseCellularNetworkCell release];
    [fAutoPortMapCell release];
    [fCheckPortButton release];
	[fEnableRPCSwitch release];
	[fRPCRequireAuthSwitch release];
	[fUseWiFiSwitch release];
	[fUseCellularNetworkSwitch release];
	[fAutoPortMapSwitch release];
	[fBindPortTextField release];
	[fRPCUsernameTextField release];
	[fRPCPasswordTextField release];
	[fRPCPortTextField release];
    [fEnableLoggingCell release];
    [fEnableLoggingSwitch release];
    [fInsomniaCell release];
    [fInsomniaSwitch release];
    self.controller = nil;
    self.indexPathToScroll = nil;
    [super dealloc];
}


@end
