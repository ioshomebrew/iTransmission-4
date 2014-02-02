//
//  PDColoredProgressView.m
//  PDColoredProgressViewDemo
//
//  Created by Pascal Widdershoven on 03-01-09.
//  Copyright 2009 Pascal Widdershoven. All rights reserved.
//  

#import "PDColoredProgressView.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
								 float ovalHeight)
{
	float fw, fh;
	// If the width or height of the corner oval is zero, then it reduces to a right angle,
	// so instead of a rounded rectangle we have an ordinary one.
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	
	//  Save the context's state so that the translate and scale can be undone with a call
	//  to CGContextRestoreGState.
	CGContextSaveGState(context);
	
	//  Translate the origin of the contex to the lower left corner of the rectangle.
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	
	//Normalize the scale of the context so that the width and height of the arcs are 1.0
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	
	// Calculate the width and height of the rectangle in the new coordinate system.
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	
	// CGContextAddArcToPoint adds an arc of a circle to the context's path (creating the rounded
	// corners).  It also adds a line from the path's last point to the begining of the arc, making
	// the sides of the rectangle.
	CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	CGContextAddLineToPoint(context, 0, fh); // Top left corner
	CGContextAddLineToPoint(context, 0, 0); // Top left corner

//	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
//	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	
	// Close the path
	CGContextClosePath(context);
	
	// Restore the context's state. This removes the translation and scaling
	// but leaves the path, since the path is not part of the graphics state.
	CGContextRestoreGState(context);
}

static void fillRectWithLinearGradient(CGContextRef context, CGRect rect, CGFloat colors[], int numberOfColors, CGFloat locations[]) {
	CGContextSaveGState(context);
	
	if(!CGContextIsPathEmpty(context))
		CGContextClip(context);
	
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(0, rect.size.height);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, numberOfColors);
	CGContextDrawLinearGradient(context, gradient, end, start, 0);
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
	CGGradientRelease(gradient);
}

@implementation PDColoredProgressView
@synthesize progress = _progress;

- (id) initWithCoder: (NSCoder*)aDecoder {
	if(self=[super initWithCoder: aDecoder]) {
		[self setTintColor: [UIColor colorWithRed: 43.0/255.0 green: 134.0/255.0 blue: 225.0/255.0 alpha: 1]];
	}
	return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {	
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		// draw rectangle
		CGContextClip(ctx);
		
        // fill empty progress bar with white
		CGContextSetRGBFillColor(ctx, 102.0f/255.0f, 102.0f/255.0f, 102.0f/255.0f, 1);
		CGContextFillRect(ctx, rect);
		
		//fill upperhalf with light grey
		CGRect upperhalf = rect;
		upperhalf.size.height /= 1.75;
		upperhalf.origin.y = 0;
		
		CGRect progressRect = rect;
		progressRect.size.width *= [self progress];
		
		CGContextClip(ctx);
		
		CGContextSetFillColorWithColor(ctx, [_tintColor CGColor]);
		CGContextFillRect(ctx, progressRect);
		
		progressRect.size.width -= 1.25;
		progressRect.origin.x += 0.625;
		progressRect.size.height -= 1.25;
		progressRect.origin.y += 0.625;
}

- (void) setTintColor: (UIColor *) aColor {
	[_tintColor release];
	_tintColor = [aColor retain];
	[self setNeedsDisplay];
}

- (void)useGreenColor
{
	[self setTintColor:[UIColor colorWithRed:112.0f/255.0f green:221.0f/255.0f blue:129.0f/255.0f alpha:1.0f]];
}

- (void)useBlueColor
{
	[self setTintColor:[UIColor colorWithRed:98.0f/255.0f green:183.0f/255.0f blue:240.0f/255.0f alpha:1.0f]];
}

- (void)useBlackColor
{
    [self setTintColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f]];
}

- (void)useWhiteColor
{
    [self setTintColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
}

- (void)dealloc {
    [super dealloc];
	[_tintColor release];
}


@end
