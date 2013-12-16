//
//  TransparentClickArea.h
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TransparentClickArea : UIView {
	UIView *fEventsForwardView;
}
@property (nonatomic, assign) IBOutlet UIView *eventsForwardView;

@end
