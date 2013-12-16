//
//  CheckboxControl.m
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckboxControl.h"

@implementation CheckboxControl
@synthesize imageView = fImageView;
@synthesize checked;
@synthesize delegate;
@synthesize checkedImage = fCheckedImage;
@synthesize uncheckedImage = fUncheckedImage;
@synthesize backwardReference = fBackwardReference;

- (id)initWithCoder:(NSCoder*)c {
    if ((self = [super initWithCoder:c])) {
        self.checkedImage = [UIImage imageNamed: @"checkbox_checked.png"];
        self.uncheckedImage = [UIImage imageNamed: @"checkbox_unchecked.png"];
        self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.imageView];
    
        self.imageView.image = self.checkedImage;
        
        [self addTarget:self action: @selector(toggle) forControlEvents: UIControlEventTouchUpInside];
    }
    return self;
}

- (void)toggle {
    [self setChecked:!checked];
    [self.delegate checkbox:self hasChangedState:checked];
}

- (void)setChecked:(BOOL)c
{
    checked = c;
    self.imageView.image = (checked ? self.checkedImage : self.uncheckedImage); 
}

- (void)dealloc {
    self.checkedImage = nil;
    self.uncheckedImage = nil;
    self.imageView = nil;
    [super dealloc];
}

@end
