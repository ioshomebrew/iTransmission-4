//
//  StatisticsViewController.h
//  iTransmission
//
//  Created by Mike Chen on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Controller;
@class StatisticsView;

@interface StatisticsViewController : UIViewController {
    StatisticsView *fStatisticsView;
    Controller *fController;
    NSTimer *fUIUpdateTimer;
}
@property (nonatomic, retain) NSTimer *UIUpdateTimer;
@property (nonatomic, retain) StatisticsView *statisticsView;
@property (nonatomic, assign) Controller *controller;

+ (id)activeController;
- (void)updateUI;

@end
