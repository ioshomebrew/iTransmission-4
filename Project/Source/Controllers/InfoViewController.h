//
//  InfoViewController.h
//  iTransmission
//
//  Created by Mike Chen on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UIWebViewDelegate>
{
    NSString *pageName;
    UIActivityIndicatorView *activityIndicator;
}
@property (nonatomic, retain) NSString *pageName;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

+ (id)infoWithPageName:(NSString*)pageName;
- (id)initWithPageName:(NSString*)pageName;

@end
