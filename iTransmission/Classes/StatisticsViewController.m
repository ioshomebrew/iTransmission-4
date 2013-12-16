//
//  StatisticsViewController.m
//  iTransmission
//
//  Created by Mike Chen on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsViewController.h"
#import "StatisticsView.h"

StatisticsViewController *__activeController;

@implementation StatisticsViewController
@synthesize statisticsView = fStatisticsView;
@synthesize controller = fController;
@synthesize UIUpdateTimer = fUIUpdateTimer;

+ (id)activeController
{
    return __activeController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)updateUI
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.statisticsView = [[StatisticsView createFromNib] autorelease];
	self.statisticsView.controller = self.controller;
	[self.view addSubview:self.statisticsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.statisticsView startUpdate];
    [self.UIUpdateTimer invalidate];
	self.UIUpdateTimer = nil;
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self updateUI];
    __activeController = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.statisticsView stopUpdate];
    [self.UIUpdateTimer invalidate];
	self.UIUpdateTimer = nil;
    
    if (__activeController == self) {
        __activeController = nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.statisticsView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    self.statisticsView = nil;
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = nil;
    [super dealloc];
}

@end
