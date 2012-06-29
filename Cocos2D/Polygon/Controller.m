//
//  Controller.m
//  Counter
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
//
//

#import "Controller.h"


@implementation Controller

@synthesize view, label, addButton, subtractButton, count, polygon;

- (UIView *)view
{
	if(view == nil)
	{
		[self loadView];
		[self viewDidLoad];
	}
	
	return view;
}

- (void)loadView
{
	[[NSBundle mainBundle] loadNibNamed:@"CounterView" owner:self options:nil];	
}

- (void)viewDidLoad
{
	count = 9;
	[self updateView];
}

- (void)updateView
{
	label.text = [NSString stringWithFormat:@"%u", count];
	
	[polygon setNumberOfSides:count];
}

- (IBAction)add
{
	subtractButton.enabled = TRUE;
	
	if(count < 25)
	{
		count++;
		
		if(count == 25)
		{
			addButton.enabled = FALSE;
		}
		else
		{
			addButton.enabled = TRUE;
		}
	}
	else
	{
		addButton.enabled = FALSE;
	}
	
	[self updateView];

}

- (IBAction)subtract
{
	addButton.enabled = TRUE;
	
	if(count > 3)
	{
		count--;
		
		if(count == 3)
		{
			subtractButton.enabled = FALSE;
		}
		else
		{
			subtractButton.enabled = TRUE;
		}
	}
	else
	{
		subtractButton.enabled = FALSE;
	}

	[self updateView];
}

@end
