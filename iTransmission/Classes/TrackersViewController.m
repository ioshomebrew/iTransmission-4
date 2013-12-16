//
//  TackersController.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import "TrackersViewController.h"

@implementation TrackersViewController

- (id)initWithTorrent:(Torrent*)t {
    self = [super initWithNibName:@"FileListViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        NSMutableArray *TrackersFromTorrent = [fTorrent allTrackerStats];
        Trackers = [[NSMutableArray alloc] init];
        for (id object in TrackersFromTorrent) {
            if ([object isKindOfClass:[TrackerNode class]]) {
                [Trackers addObject:object];
            }
        }
        self.title = @"Trackers";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)dealloc {
    [_docController release];
    self.tableView = nil;
    Trackers = nil;
    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
            NSLog(@"Count: %d", [Trackers count]);
        case 0:
            return [Trackers count];
            break;
        default:
            break;
    }
    return 0;
}

- (void)updateCell:(TrackerCell *)cell {
    if (cell == nil) {
        cell = [TrackerCell cellFromNib];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    TrackerNode *node = [Trackers objectAtIndex:indexPath.row];
    
    cell.TrackerURL.text = node.fullAnnounceAddress;
    NSLog(@"Address: %@", node.fullAnnounceAddress);
    
    cell.TrackerLastAnnounceTimeLabel.text = node.lastAnnounceStatusString;
    NSLog(@"Last Announce Status String: %@", node.lastAnnounceStatusString);
    
    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%d", [node totalSeeders]];
        NSLog(@"Total Seeders: %d", [node totalSeeders]);
    }
    
    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%d", [node totalLeechers]];
        NSLog(@"Total Leechers: %d", [node totalLeechers]);
    }
}

- (void)updateUI {
    [super updateUI];
    for (TrackerCell *cell in [self.tableView visibleCells]) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackerCell *cell = nil;
    
    cell = (TrackerCell*)[tableView dequeueReusableCellWithIdentifier:@"TrackerCell"];
    
    if (cell == nil) {
        cell = [TrackerCell cellFromNib];
    }
    
    TrackerNode *node = [Trackers objectAtIndex:indexPath.row];
    
    cell.TrackerURL.text = node.fullAnnounceAddress;
    NSLog(@"Address: %@", node.fullAnnounceAddress);
    
    cell.TrackerLastAnnounceTimeLabel.text = node.lastAnnounceStatusString;
    NSLog(@"Last Announce Status String: %@", node.lastAnnounceStatusString);
    
    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%d", [node totalSeeders]];
        NSLog(@"Total Seeders: %d", [node totalSeeders]);
    }
    
    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%d", [node totalLeechers]];
        NSLog(@"Total Leechers: %d", [node totalLeechers]);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

//document interaction
- (void) documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	
}
- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	
}
- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	
}
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
	return self.navigationController.view;
}
- (CGRect) documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
	return self.view.frame;
}

@end
