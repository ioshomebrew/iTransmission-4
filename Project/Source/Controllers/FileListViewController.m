//
//  FileListViewController.m
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileListViewController.h"
#import "FileListCell.h"
#import "Torrent.h"
#import "FileListNode.h"
#import "NSStringAdditions.h"
#import "Controller.h"

@implementation FileListViewController
@synthesize torrent = fTorrent;
@synthesize tableView = fTableView;
@synthesize docController = _docController;
@synthesize path;
@synthesize actionIndexPath;

- (id)initWithTorrent:(Torrent*)t
{
    self = [super initWithNibName:@"FileListViewController" bundle:nil];
    if (self) {
        fTorrent = t;
        self.title = @"Files";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.torrent updateFileStat];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    // start timer
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // stop timer
    [self.updateTimer invalidate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[self.torrent flatFileList] count];
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListCell *cell = nil;
    
    cell = (FileListCell*)[tableView dequeueReusableCellWithIdentifier:@"FileListCell"];
    
    if (cell == nil) {
        cell = [FileListCell cellFromNib];
    }
    
    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
    cell.filenameLabel.text = node.name;
    cell.sizeLabel.text = [NSString stringForFileSize:node.size];
    cell.progressLabel.text = [NSString percentString:[self.torrent fileProgress:node] longDecimals:NO];
    
    if ([self.torrent canChangeDownloadCheckForFiles:node.indexes]) {
        cell.checkbox.hidden = NO;
        cell.checkbox.checked = [self.torrent checkForFiles:node.indexes] == NSOnState ? YES : NO; 
        cell.checkbox.delegate = self;
        cell.checkbox.backwardReference = cell;
    }
    else {
        cell.checkbox.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];

    if ([self.torrent checkForFiles:node.indexes] == NSOnState) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)updateCell:(FileListCell*)c
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:c];
	if (indexPath) {
		FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
        c.progressLabel.text = [NSString percentString:[self.torrent fileProgress:node] longDecimals:NO];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
    NSString *p = [[[(Controller *)[UIApplication sharedApplication].delegate defaultDownloadDir] stringByAppendingPathComponent:[node path]] stringByAppendingPathComponent:[node name]];
    NSLog(@"Path : %@",p);
    if ([[NSFileManager defaultManager] fileExistsAtPath:p]) {
        NSLog(@"OpenClicked");
        
        NSString *msg = @"Would you like to use in-document viewer (beta) for this file?";
        FileListCell *cell = (FileListCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        switch ([self fileType:p]) {
            case TYPE_VIDEO:
            {
                NSLog(@"Type video");
                if([UIAlertController class])
                {
                    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self playVideo:p];
                    }];
                    [actionSheet addAction:yesAction];
                    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                    {
                        self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:p]];
                        self.docController.delegate = self;
                        [self.docController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
                    }];
                    [actionSheet addAction:noAction];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [actionSheet addAction:cancelAction];
                    [self presentViewController:actionSheet animated:YES completion:nil];
                }
                else
                {
                    self.path = p;
                    self.actionIndexPath = indexPath;
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
                    [actionSheet showFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
                }
            }
            break;
                
            case TYPE_AUDIO:
            {
                NSLog(@"Type audio");
                if([UIAlertController class])
                {
                    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self playAudio:p];
                    }];
                    [actionSheet addAction:yesAction];
                    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                               {
                                                   self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:p]];
                                                   self.docController.delegate = self;
                                                   [self.docController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
                                               }];
                    [actionSheet addAction:noAction];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [actionSheet addAction:cancelAction];
                    [self presentViewController:actionSheet animated:YES completion:nil];
                }
                else
                {
                    self.path = p;
                    self.actionIndexPath = indexPath;
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:msg delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
                    [actionSheet showFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
                }
            }
            break;
                
                case TYPE_PICTURE:
            {
                NSLog(@"Type picture");
            }
                break;
                
                case TYPE_TXT:
            {
                NSLog(@"Type txt");
            }
                break;
                
                case TYPE_PDF:
            {
                NSLog(@"Type pdf");
            }
                break;
                
                case TYPE_NULL:
            {
                NSLog(@"Unknown type");
                self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:p]];
                self.docController.delegate = self;
                [self.docController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
            }
                break;
                
            default:
                break;
        }

    }else {
        if (![self.torrent canChangeDownloadCheckForFiles:node.indexes]) {
            NSLog(@"[torrent canChangeDownloadCheckForFiles] returned false");
            return;
        }
        
        NSInteger state = [self.torrent checkForFiles:node.indexes];
        if (state == NSOnState) {
            state = NSOffState;
        }
        else {
            state = NSOnState;
        }
        
        [self.torrent setFileCheckState:state forIndexes:node.indexes];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"Yes");
            switch ([self fileType:self.path]) {
                case TYPE_VIDEO:
                {
                    NSLog(@"Type video");
                    [self playVideo:self.path];
                }
                    break;
                    
                    case TYPE_AUDIO:
                {
                    NSLog(@"Type audio");
                    [self playAudio:self.path];
                }
                    break;
                    
                    case TYPE_PICTURE:
                {
                    NSLog(@"Type picture");
                }
                    break;
                    
                    case TYPE_TXT:
                {
                    NSLog(@"Type txt");
                }
                    break;
                    
                    case TYPE_PDF:
                {
                    NSLog(@"Type pdf");
                }
                    break;
                default:
                    break;
            }
        }
        break;
            
        case 1:
        {
            NSLog(@"No");
            FileListCell *cell = (FileListCell*)[self.tableView cellForRowAtIndexPath:self.actionIndexPath];
            self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.path]];
            self.docController.delegate = self;
            [self.docController presentOpenInMenuFromRect:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, 20.0) inView:cell.contentView animated:YES];
        }
        break;
        
        default:
            break;
    }
}

- (void)playVideo:(NSString *)url
{
    NSLog(@"Play video: %@", url);
    [IJKVideoViewController presentFromViewController:self withTitle:[NSString stringWithFormat:@"File: %@", url] URL:[NSURL fileURLWithPath:url] completion:^{
    }];

}

- (void)playAudio:(NSString *)url
{
    AudioPlayer *player = [[AudioPlayer alloc] initWithNibName:@"AudioPlayer" bundle:nil file:url];
    UINavigationController *playerNav = [[UINavigationController alloc] initWithRootViewController:player];
    playerNav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerNav animated:YES completion:nil];
}

- (FileType)fileType:(NSString *)url
{
    NSArray *audioTypes = [NSArray arrayWithObjects:@"mp3", @"aac", @"adts", @"ac3", @"aif", @"aiff", @"aifc", @"caf", @"m4a", @"snd", @"au", @"sd2", @"wav", nil];
    NSArray *videoTypes = [NSArray arrayWithObjects:@"avi", @"mp4", @"fla", @"wmv", @"mkv", @"mov", @"mpg", @"m4v", nil];
    NSArray *imageTypes = [NSArray arrayWithObjects:@"tiff", @"jpeg", @"jpg", @"gif", @"png", @"dib", @"ico", @"cur", @"xbm", nil];
    NSString *extension = [url pathExtension];
    
    // check for music
    for(int i = 0; i < [audioTypes count]; i++)
    {
        if([audioTypes[i] compare:extension options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            return TYPE_AUDIO;
        }
    }
    
    // check for video
    for(int i = 0; i < [videoTypes count]; i++)
    {
        if([videoTypes[i] compare:extension options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            return TYPE_VIDEO;
        }
    }
    
    // check for image
    for(int i = 0; i < [videoTypes count]; i++)
    {
        if([imageTypes[i] compare:extension options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            return TYPE_PICTURE;
        }
    }
    
    // check for pdf
    if([extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return TYPE_PDF;
    }
    
    // check for txt
    if([extension compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return TYPE_TXT;
    }
    
    return TYPE_NULL;
}

- (void)updateUI
{
    [self.torrent updateFileStat];
        
    for (FileListCell *cell in [self.tableView visibleCells]) {
        [self performSelector:@selector(updateCell:) withObject:cell afterDelay:0.0f];
    }
}

- (void)checkbox:(id)checkbox hasChangedState:(BOOL)checked
{
    UITableViewCell *cell = (UITableViewCell*)[checkbox backwardReference];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate methods

- (void) documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"Test");
    // check for filetype
    switch ([self fileType:[controller.URL absoluteString]]) {
        case TYPE_VIDEO:
        {
            NSLog(@"Type video");
        }
        break;
        
        case TYPE_AUDIO:
        {
            NSLog(@"Type audio");
        }
        break;
            
        case TYPE_PICTURE:
        {
            NSLog(@"Type picture");
        }
        break;
            
        case TYPE_TXT:
        {
            NSLog(@"Type txt");
        }
        break;
            
        case TYPE_PDF:
        {
            NSLog(@"Type pdf");
        }
        break;
            
        case TYPE_NULL:
        {
            NSLog(@"Unknown type");
        }
        break;
            
        default:
            break;
    }
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	
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

- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	
}

@end
