//
//  ControlButton.h
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlButton : UIButton {
	NSArray *fGradientColors;	
	UILabel *fTextLabel;
	CGRect properFrame;
}
@property (nonatomic, retain) NSArray *gradientColors;
@property (nonatomic, retain) UILabel *textLabel;

- (void)useRedStyle;
- (void)useGrayStyle;
- (void)useGreenStyle;
- (void)_initViews;
- (void)hesitateUpdate;

- (void)setResumeStyle;
- (void)setPauseStyle;

@end
