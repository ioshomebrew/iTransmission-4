//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"
#import "Controller.h"

@interface SVWebViewController : UIViewController

- (id)initWithAddress:(NSString*)urlString :(Controller *)libtransmission :(UINavigationController*)nav;
- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, retain) Controller *transmission;
@property (nonatomic, retain) UINavigationController *controller;

@end
