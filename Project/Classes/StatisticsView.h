//
//  StatisticsView.h
//  iTransmission
//
//  Created by Mike Chen on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Controller;

@interface StatisticsView : UIView {
	NSTimer *fTimer;
	UIImageView *fBackgroundView;
	IBOutlet UIImageView *fUploadIcon;
	IBOutlet UIImageView *fDownloadIcon;
	IBOutlet UILabel *fDLSpeedLabel;
	IBOutlet UILabel *fULSpeedLabel;
	IBOutlet UIImageView *fStatusIndicator;
	Controller *fController;
}
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, assign) Controller *controller;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

+ (id)createFromNib;
- (void)startUpdate;
- (void)stopUpdate;
- (void)timerFired:(NSTimer *)t;
- (void)updateUI;

@end
