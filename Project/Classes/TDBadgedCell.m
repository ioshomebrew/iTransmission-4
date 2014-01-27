//
//  TDBadgedCell.m
//  TDBadgedTableCell
//	TDBageView
//
//	Any rereleasing of this code is prohibited.
//	Please attribute use of this code within your application
//
//	Any Queries should be directed to hi@tmdvs.me | http://www.tmdvs.me
//	
//  Created by Tim on [Dec 30].
//  Copyright 2009 Tim Davies. All rights reserved.
//

#import "TDBadgedCell.h"

@interface TDBadgeView ()

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSUInteger width;

@end

@implementation TDBadgeView

@synthesize width, badgeNumber, badgeColor, badgeColorHighlighted;
// from private
@synthesize font;

- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		font = [[UIFont boldSystemFontOfSize: 14] retain];
		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;	
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        font = [[UIFont boldSystemFontOfSize: 14] retain];
		
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{	
	NSString *countString = self.badgeNumber;
	
	CGSize numberSize = [countString sizeWithFont: font];
	
	self.width = numberSize.width + 16;
	
	CGRect bounds = CGRectMake(0 , 0, numberSize.width + 16 , 18);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	float radius = bounds.size.height / 2.0;
	
	CGContextSaveGState(context);
	
	UIColor *col;

    if (self.badgeColor) {
        col = self.badgeColor;
    } else {
        col = [UIColor redColor];
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, radius+1, radius+1, radius, M_PI / 2 , 3 * M_PI / 2, NO);
    CGPathAddArc(path, NULL,  bounds.size.width - radius, radius+1, radius, 3 * M_PI / 2, M_PI / 2, NO);
    CGPathCloseSubpath(path);
    
    CGFloat locations[2] = { 0.0, 0.8 };
    
    const float* end = CGColorGetComponents(col.CGColor);
    CGFloat components[8] = {
        1.0, 1.0, 1.0, end[3],          // Start color
        end[0], end[1], end[2], end[3]	// End color
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradientFill = CGGradientCreateWithColorComponents (colorSpace, components, locations, 2);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = CGRectGetMinX(pathRect);
    myStartPoint.y = CGRectGetMinY(pathRect)-10.0;
    myEndPoint.x = CGRectGetMinX(pathRect);
    myEndPoint.y = CGRectGetMaxY(pathRect);
    
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextClip(context);
    CGContextDrawLinearGradient (context, gradientFill, myStartPoint, myEndPoint, 0);
    CGContextRestoreGState(context);
    
    CGContextAddPath(context, path);
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradientFill);
    CGPathRelease(path);
	
	bounds.origin.x = (bounds.size.width - numberSize.width) / 2 +0.5;
	
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	
	[countString drawInRect:bounds withFont:self.font];
}

- (void) dealloc
{
    self.badgeNumber = nil;
	
	[font release];
	[badgeColor release];
	[badgeColorHighlighted release];
	
	[super dealloc];
}

@end


@implementation TDBadgedCell

@synthesize badgeNumber, badge, badgeColor, badgeColorHighlighted;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		badge = [[TDBadgeView alloc] initWithFrame:CGRectZero];
		
		//redraw cells in accordance to accessory
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		
		if (version <= 3.0)
			[self addSubview:self.badge];
		else 
			[self.contentView addSubview:self.badge];
		
		[self.badge setNeedsDisplay];
    }
    return self;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(self.badgeNumber)
	{
		//force badges to hide on edit.
		if(self.editing)
			[self.badge setHidden:YES];
		else
			[self.badge setHidden:NO];
		
		
		CGSize badgeSize = [self.badgeNumber sizeWithFont:[UIFont boldSystemFontOfSize: 14]];
		
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		
		CGRect badgeframe;
		
		if (version <= 3.0)
		{
			badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeSize.width+16), round((self.contentView.frame.size.height - 18) / 2), badgeSize.width+16, 18);
		}
		else
		{
			badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeSize.width+16) - 10, round((self.contentView.frame.size.height - 18) / 2), badgeSize.width+16, 18);
		}
		
		[self.badge setFrame:badgeframe];
		[badge setBadgeNumber:self.badgeNumber];
		
		if ((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeframe.origin.x)
		{
			CGFloat badgeWidth = self.textLabel.frame.size.width - badgeframe.size.width - 10.0;
			
			self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, badgeWidth, self.textLabel.frame.size.height);
		}
		
		if ((self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width) >= badgeframe.origin.x)
		{
			CGFloat badgeWidth = self.detailTextLabel.frame.size.width - badgeframe.size.width - 10.0;
			
			self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, badgeWidth, self.detailTextLabel.frame.size.height);
		}
		//set badge highlighted colours or use defaults
		if(self.badgeColorHighlighted)
			badge.badgeColorHighlighted = self.badgeColorHighlighted;
		else 
			badge.badgeColorHighlighted = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
		
		//set badge colours or impose defaults
		if(self.badgeColor)
			badge.badgeColor = self.badgeColor;
		else
			badge.badgeColor = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
	}
	else
	{
		[self.badge setHidden:YES];
	}
	
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[badge setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[badge setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing) {
		badge.hidden = YES;
		[badge setNeedsDisplay];
		[self setNeedsDisplay];
	}
	else 
	{
		badge.hidden = NO;
		[badge setNeedsDisplay];
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
	[badge release];
	[badgeColor release];
	[badgeColorHighlighted release];
	
    [super dealloc];
}


@end