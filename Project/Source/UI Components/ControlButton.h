//
//  ControlButton.h
//  iTransmission
//
//  Created by Mike Chen on 10/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlButton : UIButton

@property (nonatomic, retain) UILabel *textLabel;

- (void)_initViews;
- (void)hesitateUpdate;

- (void)setResumeStyle;
- (void)setPauseStyle;

@end
