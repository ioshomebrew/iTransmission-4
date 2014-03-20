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

- (void)useGreenColor
{
	[self.progressView setTintColor:[UIColor colorWithRed:112.0f/255.0f green:221.0f/255.0f blue:129.0f/255.0f alpha:1.0f]];
}

- (void)useBlueColor
{
	[self.progressView setTintColor:[UIColor colorWithRed:98.0f/255.0f green:183.0f/255.0f blue:240.0f/255.0f alpha:1.0f]];
}

- (void)useBlackColor
{
    [self.progressView setTintColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f]];
}

- (void)setProgress:(CGFloat)progress
{
    [self.progressView setProgress:progress];
    [self setNeedsDisplay];
}

- (IBAction)pausedPressed:(id)sender
{

}

@end
