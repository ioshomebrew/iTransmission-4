//
//  CheckboxControl.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckboxControlDelegate <NSObject>
- (void)checkbox:(id)checkbox hasChangedState:(BOOL)checked;
@end

@interface CheckboxControl : UIControl
{
    BOOL checked;
    UIImageView *fImageView;
    UIImage *fUncheckedImage;
    UIImage *fCheckedImage;
    id<NSObject> fBackwardReference;
    id<CheckboxControlDelegate> delegate;
}

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) id<CheckboxControlDelegate> delegate;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *checkedImage;
@property (nonatomic, retain) UIImage *uncheckedImage;
@property (nonatomic, assign) id<NSObject> backwardReference;
- (void)toggle;

@end
