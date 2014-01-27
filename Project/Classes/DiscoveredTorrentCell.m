//
//  DiscoveredTorrentCell.m
//  iTransmission
//
//  Created by Mike Chen on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DiscoveredTorrentCell.h"


@implementation DiscoveredTorrentCell
@synthesize filenameLabel = fFilenameLabel;
@synthesize directoryLabel = fDirectoryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [self.filenameLabel setTextColor:[UIColor whiteColor]];
        [self.directoryLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [self.filenameLabel setTextColor:[UIColor blackColor]];
        [self.directoryLabel setTextColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f]];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [self.filenameLabel setTextColor:[UIColor whiteColor]];
        [self.directoryLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [self.filenameLabel setTextColor:[UIColor blackColor]];
        [self.directoryLabel setTextColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.6f alpha:1.0f]];
    }
}

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DiscoveredTorrentCell" owner:nil options:nil];
    DiscoveredTorrentCell *cell = (DiscoveredTorrentCell*)[objects objectAtIndex:0];
    return cell;
}

- (void)dealloc
{
    self.directoryLabel = nil;
    self.filenameLabel = nil;
    [super dealloc];
}

@end
