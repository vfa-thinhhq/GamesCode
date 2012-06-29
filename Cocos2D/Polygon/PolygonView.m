//
//  PolygonView.m
//  Polygon
//
//  Created by Nick Vellios on 3/22/10.
//  Copyright 2010 Nick Vellios. All rights reserved.
//
//	http://www.Vellios.com
//	nick@vellios.com
//
//	This code is released under the "Take a kid fishing or hunting license"
//	In order to use any code in your project you must take a kid fishing or
//	hunting and give some sort of credit to the author of the code either
//	on your product's website, about box, or legal agreement.
////
#import "PolygonView.h"


@implementation PolygonView

@synthesize numberOfSides;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        // Initialization code
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGFloat ctrX = 140.0, ctrY = 140.0, radius = 120.0;
	
	for(int i = 0; i < numberOfSides; i++)
	{
		CGFloat p2x = (ctrX + radius * cosf(((M_PI / 180) * (360.0 / (CGFloat)numberOfSides) * (CGFloat)i)));
		CGFloat p2y = (ctrY + radius * sinf(((M_PI / 180) * (360.0 / (CGFloat)numberOfSides) * (CGFloat)i)));
		
		if(i == 0)
		{
			CGPathMoveToPoint(path, NULL, p2x, p2y);
		}
		else
		{
			CGPathAddLineToPoint(path, NULL, p2x, p2y);
		}
	}
	
	CGContextAddPath(context, path);
	CGContextClosePath(context);
	
	CGContextSetLineWidth(context, 10.0);
	[[UIColor blueColor] set];
	CGContextStrokePath(context);
	
	[[UIColor blackColor] set];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	
	CGPathRelease(path);
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setNumberOfSides:(NSUInteger)sides
{
	numberOfSides = sides;

	[self setNeedsDisplay];
}

@end
