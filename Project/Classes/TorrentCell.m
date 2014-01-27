//
//  TorrentCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TorrentCell.h"
#import "GradientView.h"
#import "PDColoredProgressView.h"

@implementation TorrentCell

@synthesize nameLabel = fNameLabel;
@synthesize upperDetailLabel = fUpperDetailLabel;
@synthesize lowerDetailLabel = fLowerDetailLabel;
@synthesize progressView = fProgressView;
@synthesize controlButton = fControlButton;

+ (id)cellFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TorrentCell" owner:nil options:nil];
	TorrentCell *cell = (TorrentCell*)[objects objectAtIndex:0];
	cell.backgroundView = [[[GradientView alloc] init] autorelease];
	
	CGRect progressViewRect = cell.progressView.frame;
	progressViewRect.size = CGSizeMake(progressViewRect.size.width, 14);
	cell.progressView.frame = progressViewRect;
	return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	[self.controlButton setNeedsDisplay];
}

- (void)dealloc {
	self.nameLabel = nil;
	self.upperDetailLabel = nil;
	self.lowerDetailLabel = nil;
	self.progressView = nil;
	self.controlButton = nil;
    [super dealloc];
}


@end
