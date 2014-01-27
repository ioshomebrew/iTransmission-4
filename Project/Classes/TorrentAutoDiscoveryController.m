//
//  TorrentAutoDiscoveryController.m
//  iTransmission
//
//  Created by Mike Chen on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TorrentAutoDiscoveryController.h"
#import "DiscoveredTorrentCell.h"
#import "Controller.h"

@implementation DiscoveredTorrentFile
@synthesize filepath;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.filepath = [aDecoder decodeObjectForKey:@"DTFFilepath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:filepath forKey:@"DTFFilepath"];
}

- (NSUInteger)hash {
    return [self.filepath hash];
}

- (NSString*)description
{
    return [self.filepath description];
}

- (BOOL)isEqual:(DiscoveredTorrentFile*)object
{
    return [self.filepath isEqualToString:object.filepath];
}

- (NSString*)filename
{
    return [self.filepath lastPathComponent];
}

- (NSString*)directory
{
    return [self.filepath stringByDeletingLastPathComponent];
}

- (id)initWithFilepath:(NSString *)path
{
    if ((self = [super init])) {
        self.filepath = path;
    }
    return self;
}

- (void)dealloc
{
    self.filepath = nil;
    [super dealloc];
}

@end

@implementation TorrentAutoDiscoveryController
@synthesize searchDirectories = fSearchDirectories;
@synthesize refreshHeaderView = fRefreshHeaderView;
@synthesize discoveredTorrents = fDiscoveredTorrents;
@synthesize state;
@synthesize fileManager = fFileManager;
@synthesize autoDiscoveryThread = fAutoDiscoveryThread;
@synthesize lastDiscoveryDate = fLastDiscoveryDate;
@synthesize tableView = fTableView;
@synthesize searchBar = fSearchBar;
@synthesize controller = fController;
@synthesize searchResults = fSearchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self buildSearchDirectories];
        self.discoveredTorrents = nil;
        self.fileManager = [[[NSFileManager alloc] init] autorelease];
        state = AutoDiscoveryStateIdle;
        self.discoveredTorrents = [NSMutableArray array];
        self.lastDiscoveryDate = [NSDate dateWithTimeIntervalSince1970:0];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)] autorelease];
        
        UIButton *_infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [_infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_infoButton] autorelease];
        
        self.title = @"Auto Discover";
    }
    return self;
}

- (void)dealloc
{
    self.searchDirectories = nil;
    self.fileManager = nil;
    self.refreshHeaderView = nil;
    self.discoveredTorrents = nil;
    [self.autoDiscoveryThread cancel];
    self.autoDiscoveryThread = nil;
    self.tableView = nil;
    self.searchResults = nil;
    self.searchBar = nil;
    self.lastDiscoveryDate = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)doneButtonClicked:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)infoButtonClicked:(id)sender
{
    [[[[UIAlertView alloc] initWithTitle:@"Help" message:@"Pulling down the view will activate torrent file auto discover that will find every .torrent file in your device." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    if (self.refreshHeaderView == nil) {
		self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)] autorelease];
		self.refreshHeaderView.delegate = self;
		[self.tableView addSubview:self.refreshHeaderView];		
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadFromHistories];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.state == AutoDiscoveryStateWorking)
        [self.autoDiscoveryThread cancel];
    [self saveToHistories];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)buildSearchDirectories
{
    NSMutableArray *temp = [NSMutableArray array];
    
//    [temp addObject:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
//    [temp addObject:NSHomeDirectory()];
//    [temp addObject:NSTemporaryDirectory()];
//    [temp addObject:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];

#if TARGET_IPHONE_SIMULATOR
    [temp addObject:@"/Users/ccp"];
//    [temp addObject:[[NSString alloc] initWithCString:getenv("HOME") encoding:NSASCIIStringEncoding]];
#else
    [temp addObject:@"/"];
#endif

    NSLog(@"Built %d search directories.", [temp count]);
    for (NSString *dir in temp) {
        NSLog(@"%@", dir);
    }
    self.searchDirectories = [NSArray arrayWithArray:temp];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    self.searchResults = [NSMutableArray array];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchResults = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchResults = [NSMutableArray arrayWithArray:self.discoveredTorrents];
    [self.searchResults filterUsingPredicate:[NSPredicate predicateWithFormat:@"filepath contains[c] %@", searchString]];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) 
        if (tableView == self.searchDisplayController.searchResultsTableView)
            return [self.searchResults count];
        else
            return [self.discoveredTorrents count];
    else 
        return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSUInteger row = indexPath.row;
        
        DiscoveredTorrentCell *cell = (DiscoveredTorrentCell*)[tableView dequeueReusableCellWithIdentifier:@"DiscoveredTorrentCell"];
        if (cell == nil) {
            cell = [DiscoveredTorrentCell cellFromNib];
        }
        DiscoveredTorrentFile *torrent = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
            torrent = [self.discoveredTorrents objectAtIndex:row];
        else 
            torrent = [self.discoveredTorrents objectAtIndex:row];
        cell.filenameLabel.text = [torrent filename];
        cell.directoryLabel.text = [torrent directory];
        cell.textLabel.text = nil;
        return cell;
    }
    else {
        DiscoveredTorrentCell *cell = (DiscoveredTorrentCell*)[tableView dequeueReusableCellWithIdentifier:@"DiscoveredTorrentCell"];
        if (cell == nil) {
            cell = [DiscoveredTorrentCell cellFromNib];
        }
        cell.filenameLabel.text = nil;
        cell.directoryLabel.text = nil;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        if (tableView == self.searchDisplayController.searchResultsTableView)
            cell.textLabel.text = [NSString stringWithFormat:@"%d torrents found.", [self.searchResults count]];
        else 
            cell.textLabel.text = [NSString stringWithFormat:@"%d torrents found.", [self.discoveredTorrents count]];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    }
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([indexPath section] == 0) {
        DiscoveredTorrentFile *torrent = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
            torrent = [self.discoveredTorrents objectAtIndex:row];
        else 
            torrent = [self.discoveredTorrents objectAtIndex:row];
        NSError *error = [self.controller openFile:[torrent filepath] addType:ADD_URL forcePath:nil];
        if (error) {
            [[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
        }
        else {
            [[[[UIAlertView alloc] initWithTitle:@"Success" message:@"New torrent added. " delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self startAutoDiscoveryThread];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return (self.state == AutoDiscoveryStateWorking); // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return self.lastDiscoveryDate; // should return date data source was last changed
}

- (void)autoDiscoveryFinished
{
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)loadFromHistories
{
    NSData *data = [NSData dataWithContentsOfFile:[self historiesPlistFilepath]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *loadedTorrents = [unarchiver decodeObjectForKey:@"torrents"];
    NSDate *loadedUpdateDate = [unarchiver decodeObjectForKey:@"date"];
    if ([self.lastDiscoveryDate timeIntervalSinceDate:loadedUpdateDate] < 0) {
        self.lastDiscoveryDate = loadedUpdateDate;
    }
    [self appendDiscoveredTorrents:loadedTorrents];
    [unarchiver finishDecoding];
    [unarchiver release];
}

- (void)saveToHistories
{
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:self.discoveredTorrents forKey:@"torrents"];
    [archiver encodeObject:self.lastDiscoveryDate forKey:@"date"];
    [archiver finishEncoding];
    [data writeToFile:[self historiesPlistFilepath] atomically:YES];
}

- (void)autoDiscoverySearchingAtPath:(NSString*)path
{
    NSLog(@"%@", path);
}

- (NSString*)historiesPlistFilepath
{
    return [[self.controller documentsDirectory] stringByAppendingPathComponent:@"auto_discovery_histories.plist"];
}

- (void)findTorrentFilesAtPath:(NSString*)dir
{
    NSDirectoryEnumerator *enumerator = [self.fileManager enumeratorAtPath:dir];
    NSMutableArray *torrentFiles = [NSMutableArray array];
    
    NSString *file;
    CFAbsoluteTime lastReportDirectoryTimestamp = 0.0f;
    
    while ((file = [enumerator nextObject])) {
        NSString *filepath = [dir stringByAppendingPathComponent:file];
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        
        if ([[NSThread currentThread] isCancelled]) {
            return;
        }
        
        if (now - lastReportDirectoryTimestamp > 0.2f) {
            
            if ([torrentFiles count]) {
                [self performSelectorOnMainThread:@selector(appendDiscoveredTorrents:) withObject:[NSArray arrayWithArray:torrentFiles] waitUntilDone:NO];
                torrentFiles = [NSMutableArray array];
            }
            
            BOOL isDirectory = NO;
            NSString *currentDirectory = nil;
            [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDirectory];
            if (isDirectory) {
                currentDirectory = filepath;
            }
            else {
                currentDirectory = [filepath stringByDeletingLastPathComponent];
            }
            [self autoDiscoverySearchingAtPath:currentDirectory];
            lastReportDirectoryTimestamp = now;
        }
        
        if ([[file pathExtension] isEqualToString:@"torrent"]) {
            DiscoveredTorrentFile *torrent = [[[DiscoveredTorrentFile alloc] initWithFilepath:filepath] autorelease];
            [torrentFiles addObject:torrent];
        }
        
    }
    return;
}

- (void)appendDiscoveredTorrents:(NSArray *)files
{
    if ([files count] == 0) return;
    [self.tableView beginUpdates];
    for (NSString *file in files) {
        if ([self.discoveredTorrents containsObject:file] == NO) {
            NSInteger insertRow = [self.discoveredTorrents count];
            [self.discoveredTorrents addObject:file];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertRow inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    [self.tableView endUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)startAutoDiscoveryThread
{
    if (self.autoDiscoveryThread || self.state == AutoDiscoveryStateWorking) 
        return;
    NSThread *thread = [[[NSThread alloc] initWithTarget:self selector:@selector(_autoDiscoveryMain) object:nil] autorelease];
    self.autoDiscoveryThread = thread;
    state = AutoDiscoveryStateWorking;
    [thread start];
}

- (void)autoDiscoveryThreadEnded
{
    self.autoDiscoveryThread = nil;
    self.lastDiscoveryDate = [NSDate date];
    state = AutoDiscoveryStateIdle;
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)_autoDiscoveryMain
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (NSString *searchDirectory in self.searchDirectories) {
        if ([[NSThread currentThread] isCancelled]) {
            goto FINISH;
        }
        [self findTorrentFilesAtPath:searchDirectory];
    }
    
FINISH:
    if ([[NSThread currentThread] isCancelled] == NO) {
        [self performSelectorOnMainThread:@selector(autoDiscoveryThreadEnded) withObject:nil waitUntilDone:NO];
    }
    
    [pool release];
    [NSThread exit];
}

@end
