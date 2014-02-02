//
//  TorrentViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TorrentViewController.h"
#import "Controller.h"
#import "TorrentCell.h"
#import "Torrent.h"
#import "PrefViewController.h"
#import "RegexKitLite.h"
#import "UIAlertViewPrivate.h"
#import "RegexExtension.h"
#import "TorrentFetcher.h"
#import "TDBadgedCell.h"
#import "Notifications.h"
#import "NSStringAdditions.h"
#import "DetailViewController.h"
#import "ControlButton.h"
#import "StatisticsView.h"
#import "PDColoredProgressView.h"
#import "BandwidthController.h"
#import "TorrentAutoDiscoveryController.h"
#import "InfoViewController.h"
#import "WebBrowser.h"

#define ADD_TAG 1000
#define ADD_FROM_URL_TAG 1001
#define ADD_FROM_MAGNET_TAG 1002
#define REMOVE_COMFIRM_TAG 1003

@implementation TorrentViewController

@synthesize tableView = fTableView;
@synthesize activityIndicator = fActivityIndicator;
@synthesize activityItemView = fActivityItemView;
@synthesize activityCounterBadge = fActivityCounterBadge;
@synthesize normalToolbarItems = fNormalToolbarItems;
@synthesize editToolbarItems = fEditToolbarItems;
@synthesize doneButton = fDoneButton;
@synthesize editButton = fEditButton;
@synthesize infoButton = fInfoButton;
@synthesize selectedIndexPaths = fSelectedIndexPaths;
@synthesize activityItem = fActivityItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)] autorelease];
        UIBarButtonItem *flexSpaceOne = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateUI)] autorelease];
		UIBarButtonItem *flexSpaceTwo = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *prefButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(prefButtonClicked:)] autorelease];
		UIBarButtonItem *flexSpaceThree = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *bandwidthButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bandwidth-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(bandwidthButtonClicked:)] autorelease];
		
        self.normalToolbarItems = [NSArray arrayWithObjects:addButton, flexSpaceOne, refreshButton, flexSpaceTwo, bandwidthButton, flexSpaceThree, prefButton, nil];
        self.toolbarItems = self.normalToolbarItems;
        
		UIBarButtonItem *pauseButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(resumeButtonClicked:)] autorelease];
		UIBarButtonItem *resumeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseButtonClicked:)] autorelease];
		UIBarButtonItem *removeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonClicked:)] autorelease];
		UIBarButtonItem *_flexSpaceOne = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem *_flexSpaceTwo = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		
		self.editToolbarItems = [NSArray arrayWithObjects:resumeButton, _flexSpaceOne, pauseButton, _flexSpaceTwo, removeButton, nil];
        
		self.title = @"Transfers";
		self.controller = (Controller*)[[UIApplication sharedApplication] delegate];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedTorrents:) name:NotificationTorrentsRemoved object:self.controller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCounterDidChange:) name:NotificationActivityCounterChanged object:self.controller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTorrentAdded:) name:NotificationNewTorrentAdded object:self.controller];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.controller torrentsCount];
        
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing == NO) {
		DetailViewController *detailController = [[[DetailViewController alloc] initWithTorrent:[self.controller torrentAtIndex:indexPath.row] controller:self.controller] autorelease];
		[self.navigationController pushViewController:detailController animated:YES];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		if ([self.selectedIndexPaths count] == 0) {
			for (UIBarButtonItem *item in self.editToolbarItems) {
				[item setEnabled:YES];
			}
		}
		[self.selectedIndexPaths addObject:indexPath];
		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton useGrayStyle];
		[cell.controlButton setEnabled:NO];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing == NO) {
	}
	else {
		[self.selectedIndexPaths removeObject:indexPath];
		if ([self.selectedIndexPaths count] == 0) {
			for (UIBarButtonItem *item in self.editToolbarItems) {
				[item setEnabled:NO];
			}
		}		
		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton useGrayStyle];
		[cell.controlButton setEnabled:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TorrentCell *cell = (TorrentCell*)[tableView dequeueReusableCellWithIdentifier:TorrentCellIdentifier];
    
    if (!cell) {
        cell = [TorrentCell cellFromNib];
		[cell.controlButton addTarget:self action:@selector(controlButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
    
    Torrent *t = [self.controller torrentAtIndex:index];
    [self setupCell:cell forTorrent:t];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f; 
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
	return UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}
       
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Torrent * torrent = [self.controller torrentAtIndex:indexPath.row];
	NSLog(@"Should delete torrent %@", [torrent name]);
}

- (void)addButtonClicked:(id)sender
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Add from..." delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    [sheet addButtonWithTitle:@"Web"];
    [sheet addButtonWithTitle:@"Magnet"];
    [sheet addButtonWithTitle:@"URL"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:3];
    [sheet setTag:ADD_TAG];
    [sheet showFromToolbar:self.navigationController.toolbar];
}

- (void)bandwidthButtonClicked:(id)sender
{
    BandwidthController *c = [[[BandwidthController alloc] initWithNibName:@"BandwidthController" bundle:nil] autorelease];
    c.torrent = nil;
    c.controller = self.controller;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:c] autorelease];
    [self presentModalViewController:navController animated:YES];
}

- (void)infoButtonClicked:(id)sender
{
    InfoViewController *viewController = [InfoViewController infoWithPageName:@"about"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)prefButtonClicked:(id)sender
{
    PrefViewController *prefViewController = [[[PrefViewController alloc] initWithNibName:@"PrefViewController" bundle:nil] autorelease];
    UINavigationController *prefNav = [[[UINavigationController alloc] initWithRootViewController:prefViewController] autorelease];
    [self presentModalViewController:prefNav animated:YES];
}

- (void)controlButtonClicked:(id)sender
{
    UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	
	Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
	if ([torrent isActive])
		[torrent stopTransfer];
	else 
		[torrent startTransfer];
	
	//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setupCell:(TorrentCell*)cell forTorrent:(Torrent*)t
{
	[t update];
	cell.nameLabel.text = [t name];
	cell.upperDetailLabel.text = [t progressString];
	if (![t isChecking]) {
        [cell.progressView setProgress:[t progress]];
    }
    
	if ([t isSeeding])
		[cell.progressView useGreenColor];
	else if ([t isChecking]) {
		[cell.progressView useGreenColor];
        [cell.progressView setProgress:[t checkingProgress]];
    }
	else if ([t isActive] && ![t isComplete])
		[cell.progressView useBlueColor];
	else if (![t isActive])
		[cell.progressView useGrayColor];
	else if (![t isChecking])
		[cell.progressView useGreenColor];
	if ([t isActive])
		[cell.controlButton setPauseStyle];
	else 
		[cell.controlButton setResumeStyle];

	if (![self.controller isStartingTransferAllowed]) {
		[cell.controlButton useGrayStyle];
		[cell.controlButton setEnabled:NO];
	}
	else {
		[cell.controlButton setEnabled:YES];
	}
	cell.lowerDetailLabel.text = [t statusString];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
    self.activityItemView.backgroundColor = [UIColor clearColor];
    self.activityItem = [[[UIBarButtonItem alloc] initWithCustomView:self.activityItemView] autorelease];	
		
	UIButton *_infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[_infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.infoButton = [[[UIBarButtonItem alloc] initWithCustomView:_infoButton] autorelease];
	self.navigationItem.rightBarButtonItem = self.infoButton;
	
	self.editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)] autorelease];
	self.navigationItem.leftBarButtonItem = self.editButton;
	
	self.doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)] autorelease];
	
    [self.activityCounterBadge setBadgeColor:[UIColor colorWithRed:0.82 green:0.0 blue:0.082 alpha:1.000]];
	
//	self.statisticsView = [StatisticsView createFromNib];
//	self.statisticsView.controller = self.controller;
//	[self.view addSubview:self.statisticsView];
}

- (void)resumeButtonClicked:(id)sender
{
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[torrent startTransfer];
	}
	[self.tableView reloadData];
	self.selectedIndexPaths = nil;	
}

- (void)pauseButtonClicked:(id)sender
{
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[torrent stopTransfer];
	}
	[self.tableView reloadData];
	self.selectedIndexPaths = nil;
}

- (void)removeButtonClicked:(id)sender
{
	NSString *msg;
	if ([self.selectedIndexPaths count] == 1)
		msg = @"Are you sure to remove one torrent?";
	else 
		msg = [NSString stringWithFormat:@"Are you sure to remove %i torrents?", [self.selectedIndexPaths count]];

	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes and remove data" otherButtonTitles:@"Yes but keep data", nil] autorelease];
	actionSheet.tag = REMOVE_COMFIRM_TAG;
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)editButtonClicked:(id)sender
{
	for (UIBarButtonItem *item in self.editToolbarItems) {
		[item setEnabled:NO];
	}
	[self.tableView setEditing:YES animated:YES];
	[self.navigationItem setLeftBarButtonItem:self.doneButton animated:YES];
	[self setToolbarItems:self.editToolbarItems animated:YES];
	self.selectedIndexPaths = [NSMutableArray array];
}

- (void)doneButtonClicked:(id)sender
{
	[self.tableView setEditing:NO animated:YES];
	[self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
	[self setToolbarItems:self.normalToolbarItems animated:YES];
	
	for (NSIndexPath *indexPath in self.selectedIndexPaths) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	self.selectedIndexPaths = nil;
}

- (void)updateUI
{
    [super updateUI];
	NSArray *visibleCells = [self.tableView visibleCells];
	
	for (TorrentCell *cell in visibleCells) {
		[self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
	}
}
	
- (void)updateCell:(TorrentCell*)c
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:c];
	if (indexPath) {
		Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
		[self setupCell:c forTorrent:torrent];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
	self.statisticsView = nil;
	self.editButton = nil;
	self.doneButton = nil;
	self.selectedIndexPaths = nil;
}

- (void)addFromWebClicked
{
    // [self addFromURLWithExistingURL:@"" message:@"Please enter the torrent's URL below. "];
    WebBrowser *web = [[WebBrowser alloc] initWithNibName:@"WebBrowser"
                                                   bundle:nil
                                   navigigationController:self.navigationController
                                               controller:self.controller];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)addFromURLClicked
{
    [self addFromURLWithExistingURL:@"" message:@"Please enter the existing torrent's URL"];
}

- (void)addFromURLWithExistingURL:(NSString*)url message:(NSString*)msg
{
    UIAlertView *dialog = [[[UIAlertView alloc] initWithTitle:@"Add from URL" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    dialog.delegate = self;
    dialog.tag = ADD_FROM_URL_TAG;
    [dialog addTextFieldWithValue:url label:@"http://"];
    UITextField *textField = [dialog textField];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.enablesReturnKeyAutomatically = YES;
    textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = NO;
    [dialog show];
}

- (void)addFromMagnetWithExistingMagnet:(NSString*)magnet message:(NSString*)msg
{
    UIAlertView *dialog = [[[UIAlertView alloc] initWithTitle:@"Add from magnet" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    dialog.delegate = self;
    dialog.tag = ADD_FROM_MAGNET_TAG;
    [dialog addTextFieldWithValue:magnet label:@"magnet:"];
    UITextField *textField = [dialog textField];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.enablesReturnKeyAutomatically = YES;
    textField.keyboardAppearance = UIKeyboardAppearanceDefault;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeyDone;
    textField.secureTextEntry = NO;
    [dialog show];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if (alertView.tag == ADD_FROM_URL_TAG || alertView.tag == ADD_FROM_MAGNET_TAG) {
//        [UIView beginAnimations:@"Lift Alert View" context:nil];
//        CGPoint center = alertView.center;
//        center.y = center.y - 100;
//        alertView.center = center;
//        [UIView setAnimationDuration:0.3f];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView commitAnimations];
    }
}

- (void)activityCounterDidChange:(NSNotification*)notif
{
    NSInteger num = self.controller.activityCounter;
    if (num > 0) {
		self.navigationItem.rightBarButtonItem = self.activityItem;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.activityCounterBadge setHidden:NO];
        [self.activityCounterBadge setBadgeNumber:[NSString stringWithFormat:@"%i", num]];
        [self.activityCounterBadge setNeedsDisplay];
    }
    else if (num == 0) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.activityCounterBadge setHidden:YES];
		self.navigationItem.rightBarButtonItem = self.infoButton;
    }
}

- (void)newTorrentAdded:(NSNotification*)notif
{
    [self.tableView reloadData];
}

- (void)removedTorrents:(NSNotification*)notif
{
	[self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ADD_FROM_URL_TAG) {
        if (buttonIndex == 0) // cancelled
            return;
        if (buttonIndex == 1) {
            NSString *url = [[alertView textField] text];
            if (![url isURL])
                [self addFromURLWithExistingURL:url message:@"Error: The URL provided is malformed!"];
            else {
                [self.controller addTorrentFromURL:url];
            }
        }
    }
    if (alertView.tag == ADD_FROM_MAGNET_TAG) {
        if (buttonIndex == 0) // cancelled
            return;
        if (buttonIndex == 1) {
            NSString *magnet = [[alertView textField] text];
            NSError *error = [self.controller addTorrentFromManget:magnet];
            if (error)
                [self addFromMagnetWithExistingMagnet:magnet message:[error localizedDescription]];
        }
    }
}

- (void)addFromMagnetClicked
{
    [self addFromMagnetWithExistingMagnet:@"" message:@"Please enter the magnet link below. "];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case ADD_TAG: {
            switch (buttonIndex) {
                case 0: {
                    [self addFromWebClicked];
                    break;
                }
                case 1: {
                    [self addFromMagnetClicked];
                    break;
                }
                case 2: {
                    [self addFromURLClicked];
                }
                default: 
                    return;
            }
			break;
        }
		case REMOVE_COMFIRM_TAG: {
			if (buttonIndex == actionSheet.cancelButtonIndex) {
				self.selectedIndexPaths = [NSMutableArray array];
			}
			else {
				NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:[self.selectedIndexPaths count]];
				for (NSIndexPath *indexPath in self.selectedIndexPaths) {
					Torrent *t = [self.controller torrentAtIndex:indexPath.row];
					[torrents addObject:t];
				}
				[self.controller removeTorrents:torrents trashData:(buttonIndex == [actionSheet destructiveButtonIndex])];
				self.selectedIndexPaths = [NSMutableArray array];
				[self.tableView reloadData];
			}
		}
    }
}

- (void)dealloc {
    self.tableView = nil;
	self.statisticsView = nil;
	self.editButton = nil;
	self.doneButton = nil;
	self.infoButton = nil;
	self.selectedIndexPaths = nil;
    self.activityCounterBadge = nil;
	self.activityItem = nil;
    self.activityItemView = nil;
    self.activityIndicator = nil;
	self.normalToolbarItems = nil;
	self.editToolbarItems = nil;
    [super dealloc];
}


@end
