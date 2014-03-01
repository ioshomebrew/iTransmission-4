//
//  TackersController.m
//  iTransmission
//
//  Created by Dhruvit Raithatha on 16/12/13.
//
//

#import "TrackersViewController.h"

#define ADD_FROM_URL 010
#define ADD_TRACKER_BUTTON 1002
#define REMOVE_TRACKER_BUTTON 1003

@implementation TrackersViewController

- (id)initWithTorrent:(Torrent*)t {
    self = [super initWithNibName:@"TrackersViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        self.title = @"Trackers";
        SelectedItems = [[NSMutableArray alloc] init];
        Trackers = [[NSMutableArray alloc] init];
        [self reloadTrackers];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidLoad {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonTouched)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched)];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonTouched)];
    UIBarButtonItem *emptyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(addButtonTouched)];
    [addButton setTag:ADD_TRACKER_BUTTON];
    [removeButton setTag:REMOVE_TRACKER_BUTTON];
    [addButton setEnabled:NO];
    [removeButton setEnabled:NO];
    [self setToolbarItems:[NSArray arrayWithObjects:emptyButton, addButton, emptyButton, removeButton, emptyButton, nil]];
    [super viewDidLoad];
}

- (void)reloadTrackers {
    [Trackers removeAllObjects];
    for (id object in [fTorrent allTrackerStats]) {
        if ([object isKindOfClass:[TrackerNode class]]) {
            if (object != nil) {
                [Trackers addObject:object];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ADD_FROM_URL) {
        if (buttonIndex == 0)
            return;
        if (buttonIndex == 1) {
            NSString *url = [[alertView textField] text];
            BOOL exists = NO;
            for (TrackerNode *node in Trackers) {
                if (!exists) {
                    if ([node fullAnnounceAddress] == url) {
                        exists = YES;
                    }
                }
            }
            if (![url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"udp://"] || exists) {
                if (!exists) {[[[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"The URL you entered is invalid. Just where did you get it?"
                                          delegate:nil
                                                cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];}
                else {[[[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"A tracker with the same URL already exists, so both of them are the same trackers."
                                                delegate:nil
                                        cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];}
            } else {
                [fTorrent addTrackerToNewTier:url];
            }
        }
        [self reloadTrackers];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    }
}

- (void)addButtonTouched {
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"Add Tracker"
                                                      message:@"Enter the full tracker URL"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    dialog.delegate = self;
    dialog.tag = ADD_FROM_URL;
    [dialog addTextFieldWithValue:@"" label:@"Enter tracker URL"];
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

- (void)removeButtonTouched {
    for (TrackerCell *cell in SelectedItems) {
        [fTorrent removeTrackers:[NSSet setWithObject: [[cell TrackerURL] text]]];
    }
    [self reloadTrackers];
    [self.tableView reloadData];
}
- (void)editButtonTouched {
    for (UIBarButtonItem *item in self.toolbarItems) {
        if (item.tag == ADD_TRACKER_BUTTON) {
            [item setEnabled:YES];
        }
    }
    [self.tableView setEditing:YES animated:YES];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonTouched)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
}

- (void)doneButtonTouched {
    for (UIBarButtonItem *item in self.toolbarItems) {
        [item setEnabled:NO];
    }
    [self.tableView setEditing:NO animated:YES];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editButtonTouched)];
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        for (UIBarButtonItem *item in self.toolbarItems) {
            if (item.tag == REMOVE_TRACKER_BUTTON) {
                [item setEnabled:YES];
            }
        }
        TrackerCell *cell = (TrackerCell*)[tableView cellForRowAtIndexPath:indexPath];
        [SelectedItems addObject:cell];
    }
    [self reloadTrackers];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackerCell *cell = (TrackerCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([SelectedItems containsObject:cell]) {
        [SelectedItems removeObject:cell];
    }
    if ([SelectedItems count] == 0) {
        for (UIBarButtonItem *item in self.toolbarItems) {
            if (item.tag == REMOVE_TRACKER_BUTTON) {
                NSLog(@"Disabling Delete");
                [item setEnabled:NO];
            }
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
            NSLog(@"Count: %lu", (unsigned long)[Trackers count]);
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
    
    cell.TrackerLastAnnounceTime.text = node.lastAnnounceStatusString;
    
    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalSeeders]];
    }
    
    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalLeechers]];
    }
    if ((SelectedItems != nil) && ([SelectedItems count] > 0)) {
        for (TrackerCell *cell in SelectedItems) {
            [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell*)cell]
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    [self.tableView reloadData];
}

- (void)updateUI {
    
    [super updateUI];
    for (TrackerCell *cell in [self.tableView visibleCells]) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:1];
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
    
    cell.TrackerLastAnnounceTime.text = node.lastAnnounceStatusString;
    
    if (!([node totalSeeders]) || [node totalSeeders] == -1) {
        cell.SeedNumber.text = @"0";
    } else {
        cell.SeedNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalSeeders]];
    }
    
    if (!([node totalLeechers]) || [node totalLeechers] == -1) {
        cell.PeerNumber.text = @"0";
    } else {
        cell.PeerNumber.text = [NSString stringWithFormat:@"%ld", (long)[node totalLeechers]];
    }
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryCheckmark;
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
