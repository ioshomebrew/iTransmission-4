//
//  TorrentCell.h
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TorrentCellIdentifier @"TorrentCellIdentifier"

@class PDColoredProgressView;
@class ControlButton;
@interface TorrentCell : UITableViewCell {
    UILabel *fNameLabel;
	PDColoredProgressView *fProgressView;
	UILabel *fUpperDetailLabel;
	UILabel *fLowerDetailLabel;
	ControlButton *fControlButton;
}
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet PDColoredProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *upperDetailLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowerDetailLabel;
@property (nonatomic, retain) IBOutlet ControlButton *controlButton;

+ (id)cellFromNib;

@end
