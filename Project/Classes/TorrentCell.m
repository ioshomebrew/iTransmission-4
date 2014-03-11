//
//  TorrentCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TorrentCell.h"
#import "PDColoredProgressView.h"

@implementation TorrentCell

@synthesize nameLabel;
@synthesize upperDetailLabel;
@synthesize lowerDetailLabel;
@synthesize progressView;
@synthesize controlButton;

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TorrentCell" owner:nil options:nil];
	TorrentCell *cell = (TorrentCell*)[objects objectAtIndex:0];
	
	return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}

- (IBAction)pausedPressed:(id)sender
{

}

@end
