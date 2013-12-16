//
//  StatisticsView.m
//  iTransmission
//
//  Created by Mike Chen on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StatisticsView.h"
#import "Controller.h"
#import "NSStringAdditions.h"

@implementation StatisticsView
@synthesize updateTimer = fTimer;
@synthesize controller = fController;
@synthesize backgroundView = fBackgroundView;

- (id)initWithCoder:(NSCoder*)c {
    if ((self = [super initWithCoder:c])) {
    }
    return self;
}

+ (id)createFromNib
{
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StatisticsView" owner:nil options:nil];
	StatisticsView *v = (StatisticsView*)[objects objectAtIndex:0];
	[v setFrame:CGRectMake(0, 0, 320, 20)];
	[v.backgroundView setImage:[[UIImage imageNamed:@"status-view-background"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    
	return [v retain];
}

- (void)startUpdate
{
    [self.updateTimer invalidate];
    
    if (self.controller == nil) {
        self.controller = (Controller*)[[UIApplication sharedApplication] delegate];
    }
    
	self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	[self timerFired:self.updateTimer];
}

- (void)stopUpdate
{
	[self.updateTimer invalidate];
	self.updateTimer = nil;
}

- (void)timerFired:(NSTimer*)t
{
	[self updateUI];
}

- (void)updateUI
{
    [self.controller updateGlobalSpeed];
	[fDLSpeedLabel setText:[NSString stringForSpeed:[self.controller globalDownloadSpeed]]];
	[fULSpeedLabel setText:[NSString stringForSpeed:[self.controller globalUploadSpeed]]];
	if ([self.controller isSessionActive]) 
		[fStatusIndicator setImage:[UIImage imageNamed:@"GreenDot.png"]];
	else 
		[fStatusIndicator setImage:[UIImage imageNamed:@"YellowDot.png"]];
}

- (void)dealloc {
	[self.updateTimer invalidate];
	self.updateTimer = nil;
	[fUploadIcon release];
	[fDownloadIcon release];
	[fULSpeedLabel release];
	[fDLSpeedLabel release];
	[fBackgroundView release];
	[fStatusIndicator release];
    [super dealloc];
}


@end
