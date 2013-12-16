//
//  ClipboardLabel.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClipboardLabel.h"


@implementation ClipboardLabel
@synthesize shouldPopUpControlMenu;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		shouldPopUpControlMenu = YES;
		UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		[self addGestureRecognizer:gr];
		[gr release]; 
	}
	return self;
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (CGRectContainsPoint(self.bounds, point))
		return self;
	return [super hitTest:point withEvent:event];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if(action == @selector(copy:)) {
		return YES;
	}
	else {
		return [super canPerformAction:action withSender:sender];
	}
}

- (void)copy:(id)sender {
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	[board setValue:self.text forPasteboardType:@"public.utf8-plain-text"];
	[self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)showMenuFromLocation:(CGPoint)location
{
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	if ([self becomeFirstResponder]) {
		[menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:self];
		[menuController setMenuVisible:YES animated:YES];
	}
}

- (void)longPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
		[self showMenuFromLocation:location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([[touches anyObject] tapCount] == 2) {
		[self showMenuFromLocation:[[touches anyObject] locationInView:self]];
	}
}

- (void)dealloc
{
	[super dealloc];
}

@end
