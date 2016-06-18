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
#import "UIAlertViewPrivate.h"
#import "TDBadgedCell.h"
#import "Notifications.h"
#import "NSStringAdditions.h"
#import "DetailViewController.h"
#import "ControlButton.h"
#import "PDColoredProgressView.h"
#import "BandwidthController.h"

#define ADD_TAG 1000
#define ADD_FROM_URL_TAG 1001
#define ADD_FROM_MAGNET_TAG 1002
#define REMOVE_COMFIRM_TAG 1003

@implementation TorrentViewController

@synthesize tableView;
@synthesize activityIndicator;
@synthesize activityItemView;
@synthesize activityCounterBadge;
@synthesize normalToolbarItems;
@synthesize selectedIndexPaths;
@synthesize activityItem;
@synthesize audio;
@synthesize recorder;
@synthesize pref;
@synthesize bannerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
        UIBarButtonItem *flexSpaceOne = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *flexSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *prefButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(prefButtonClicked:)];
		
        self.normalToolbarItems = [NSArray arrayWithObjects:addButton, flexSpaceOne, flexSpaceTwo, prefButton, nil];
        self.toolbarItems = self.normalToolbarItems;
        
		self.title = @"Transfers";
		self.controller = (Controller*)[[UIApplication sharedApplication] delegate];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removedTorrents:) name:NotificationTorrentsRemoved object:self.controller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCounterDidChange:) name:NotificationActivityCounterChanged object:self.controller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTorrentAdded:) name:NotificationNewTorrentAdded object:self.controller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAudio:) name:@"AudioPrefChanged" object:self.pref];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordAudio:) name:@"MicrophonePrefChanged" object:self.pref];
        
        // load audio
        NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"phone" withExtension:@"mp3"];
        self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        self.audio.numberOfLoops = -1;
        [self.audio setVolume:0.0];
        
        // only play if enabled
        NSUserDefaults *fDefaults = [NSUserDefaults standardUserDefaults];
        if([fDefaults boolForKey:@"BackgroundDownloading"])
        {
            if([fDefaults boolForKey:@"UseMicrophone"])
            {
                // enable audio recording
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                
                NSString *soundFilePath = @"/dev/null";
                NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
                NSDictionary *recordSettings = [NSDictionary
                                                dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:AVAudioQualityMin],
                                                AVEncoderAudioQualityKey,
                                                [NSNumber numberWithInt:16],
                                                AVEncoderBitRateKey,
                                                [NSNumber numberWithInt: 2],
                                                AVNumberOfChannelsKey,
                                                [NSNumber numberWithFloat:44100.0],
                                                AVSampleRateKey,
                                                nil];
                self.recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:nil];
                [self.recorder record];
            }
            else
            {
                // play audio
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
                [[AVAudioSession sharedInstance] setActive: YES error: nil];
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                [self.audio play];
            }
        }
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

- (void)tableView:(UITableView *)ftableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing == NO) {
		DetailViewController *detailController = [[DetailViewController alloc] initWithTorrent:[self.controller torrentAtIndex:indexPath.row] controller:self.controller];
		[self.navigationController pushViewController:detailController animated:YES];
		[ftableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		[self.selectedIndexPaths addObject:indexPath];
		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton setEnabled:NO];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.tableView.editing == NO) {
	}
	else {
		[self.selectedIndexPaths removeObject:indexPath];
		TorrentCell *cell = (TorrentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.controlButton setEnabled:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)ftableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    TorrentCell *cell = (TorrentCell*)[ftableView dequeueReusableCellWithIdentifier:TorrentCellIdentifier];
    
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
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}
       
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Torrent * torrent = [self.controller torrentAtIndex:indexPath.row];
    self.selectedIndexPaths = [NSMutableArray array];
    [self.selectedIndexPaths addObject:indexPath];
    NSString *msg = [NSString stringWithFormat:@"Are you sure to remove %@ torrent?", [torrent name]];

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeDataAction = [UIAlertAction actionWithTitle:@"Yes and remove data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:YES];
    }];
    [actionSheet addAction:removeDataAction];

    UIAlertAction *keepDataAction = [UIAlertAction actionWithTitle:@"Yes, but keep data" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:NO];
    }];
    [actionSheet addAction:keepDataAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.selectedIndexPaths = [NSMutableArray array];
    }];
    [actionSheet addAction:cancelAction];

    if (actionSheet.popoverPresentationController != nil) {
        actionSheet.popoverPresentationController.sourceView = self.tableView;
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)addButtonClicked:(id)sender
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Add from …" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *webAction = [UIAlertAction actionWithTitle:@"Web" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addFromWebClicked];
    }];
    [sheet addAction:webAction];

    UIAlertAction *magnetAction = [UIAlertAction actionWithTitle:@"Magnet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addFromMagnetClicked];
    }];
    [sheet addAction:magnetAction];

    UIAlertAction *URLAction = [UIAlertAction actionWithTitle:@"URL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addFromURLClicked];
    }];
    [sheet addAction:URLAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [sheet addAction:cancelAction];

    if (sheet.popoverPresentationController != nil) {
        sheet.popoverPresentationController.barButtonItem = (UIBarButtonItem *)sender;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)prefButtonClicked:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        PrefViewController *prefViewController = [[PrefViewController alloc] initWithNibName:@"PrefViewController" bundle:nil];
        UINavigationController *prefNav = [[UINavigationController alloc] initWithRootViewController:prefViewController];
        prefNav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:prefNav animated:YES completion:nil];
    }
    else
    {
        PrefViewController *prefViewController = [[PrefViewController alloc] initWithNibName:@"PrefViewController" bundle:nil];
        UINavigationController *prefNav = [[UINavigationController alloc] initWithRootViewController:prefViewController];
        prefNav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:prefNav animated:YES completion:nil];
    }
}

- (void)controlButtonClicked:(id)sender
{
    CGPoint pos = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
	
	Torrent *torrent = [self.controller torrentAtIndex:indexPath.row];
	if ([torrent isActive])
		[torrent stopTransfer];
	else 
		[torrent startTransfer];
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
		[cell useGreenColor];
	else if ([t isChecking]) {
		[cell useGreenColor];
        [cell.progressView setProgress:[t checkingProgress]];
    }
	else if ([t isActive] && ![t isComplete])
		[cell useBlueColor];
	else if (![t isActive])
		[cell useBlueColor];
	else if (![t isChecking])
		[cell useGreenColor];
	if ([t isActive])
		[cell.controlButton setPauseStyle];
	else 
		[cell.controlButton setResumeStyle];

	if (![self.controller isStartingTransferAllowed]) {
		[cell.controlButton setEnabled:NO];
	}
	else {
		[cell.controlButton setEnabled:YES];
	}
	cell.lowerDetailLabel.text = [t statusString];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
    // init admob
    self.bannerView.adUnitID = @"ca-app-pub-5972525945446192/5283882861";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
    
    self.activityItemView.backgroundColor = [UIColor clearColor];
    self.activityItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityItemView];
	
    [self.activityCounterBadge setBadgeColor:[UIColor colorWithRed:0.82 green:0.0 blue:0.082 alpha:1.000]];
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
    if ([self.selectedIndexPaths count] == 1) {
		msg = @"Are you sure to remove one torrent?";
    } else {
		msg = [NSString stringWithFormat:@"Are you sure to remove %lu torrents?", (unsigned long)[self.selectedIndexPaths count]];
    }

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeDataAction = [UIAlertAction actionWithTitle:@"Yes and remove data" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:YES];
    }];
    [actionSheet addAction:removeDataAction];

    UIAlertAction *keepDataAction = [UIAlertAction actionWithTitle:@"Yes, but keep data" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeTorrentsTrashData:NO];
    }];
    [actionSheet addAction:keepDataAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.selectedIndexPaths = [NSMutableArray array];
    }];
    [actionSheet addAction:cancelAction];

    if (actionSheet.popoverPresentationController != nil) {
        actionSheet.popoverPresentationController.sourceView = (UIView *)sender;
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)removeTorrentsTrashData:(BOOL)trashData {
    NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:[self.selectedIndexPaths count]];
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        Torrent *t = [self.controller torrentAtIndex:indexPath.row];
        [torrents addObject:t];
    }
    [self.controller removeTorrents:torrents trashData:trashData];
    self.selectedIndexPaths = [NSMutableArray array];
    [self.tableView reloadData];
}

- (void)updateUI
{
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
}

- (void)addFromURLClicked
{
    [self addFromURLWithExistingURL:@"" message:@"Please enter the existing torrent's URL"];
}

- (void)addFromURLWithExistingURL:(NSString*)url message:(NSString*)msg
{

    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from URL" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = dialog.textFields.firstObject.text;
        if (![url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
            [self addFromURLWithExistingURL:url message:@"Error: The URL provided is malformed!"];
        else {
            [self.controller addTorrentFromURL:url];
        }
    }];
    [dialog addAction:okAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [dialog addAction:cancelAction];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)addFromMagnetWithExistingMagnet:(NSString*)magnet message:(NSString*)msg
{
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Add from magnet" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *magnet = dialog.textFields.firstObject.text;
        NSError *error = [self.controller addTorrentFromManget:magnet];
        if (error) {
            [self addFromMagnetWithExistingMagnet:magnet message:[error localizedDescription]];
        }
    }];
    [dialog addAction:okAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [dialog addAction:cancelAction];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = NO;
    }];

    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)activityCounterDidChange:(NSNotification*)notif
{
    NSInteger num = self.controller.activityCounter;
    if (num > 0) {
		self.navigationItem.rightBarButtonItem = self.activityItem;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.activityCounterBadge setHidden:NO];
        [self.activityCounterBadge setBadgeNumber:[NSString stringWithFormat:@"%li", (long)num]];
        [self.activityCounterBadge setNeedsDisplay];
    }
    else if (num == 0) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.activityCounterBadge setHidden:YES];
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

- (void)playAudio:(NSNotification *)notif
{
    // load audio
    NSURL *audioURL = [[NSBundle mainBundle] URLForResource:@"phone" withExtension:@"mp3"];
    self.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.audio.numberOfLoops = -1;
    [self.audio setVolume:0.0];
    
    // only play if enabled
    NSNumber *value = notif.object;
    if(value)
    {
        // play audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self.audio play];
    }
    else
    {
        // stop audio
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: NO error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self.audio stop];
    }
}

- (void)recordAudio:(NSNotification *)notif
{
    // stop audio
    [audio stop];
    
    // only record when enabled
    NSNumber *value = notif.object;
    if(value)
    {
        // enable audio recording
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        NSString *soundFilePath = @"/dev/null";
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16],
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:nil];
        [self.recorder record];
    }
    else
    {
        [self.recorder stop];
    }
}

- (void)addFromMagnetClicked
{
    [self addFromMagnetWithExistingMagnet:@"" message:@"Please enter the magnet link below. "];
}

- (void)addFromWebClicked
{
    NSString *URL = @"https://google.com";
	//SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:URL controller:self.controller navigationController:self.navigationController];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    // start timer
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // stop update timer
    [self.updateTimer invalidate];
}

@end
