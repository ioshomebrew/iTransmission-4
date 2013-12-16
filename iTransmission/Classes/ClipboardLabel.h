//
//  ClipboardLabel.h
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ClipboardLabel : UILabel {
	BOOL shouldPopUpControlMenu;
}
@property (nonatomic, assign) BOOL shouldPopUpControlMenu;

- (BOOL)canBecomeFirstResponder;
- (void)longPress:(UILongPressGestureRecognizer*) gestureRecognizer;
- (void)copy:(id)sender;
- (void)showMenuFromLocation:(CGPoint)location;

@end
